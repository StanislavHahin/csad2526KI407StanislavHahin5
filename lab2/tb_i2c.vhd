library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_i2c is
end entity;

architecture sim of tb_i2c is

    -- системний такт
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';

    -- для TX
    signal start_tx  : std_logic := '0';
    signal data_in   : std_logic_vector(7 downto 0) := (others => '0');
    signal scl_tx    : std_logic;
    signal sda_tx    : std_logic := 'Z';
    signal tx_done   : std_logic;
    signal ack_in    : std_logic := '1';

    -- для RX
    signal start_rx  : std_logic := '0';
    signal scl_rx    : std_logic;
    signal sda_rx    : std_logic := '1';
    signal rx_data   : std_logic_vector(7 downto 0);
    signal rx_done   : std_logic;

begin

    -------------------------------------------------------------------------
    -- Генерація системного такту (20 нс – 50 МГц)
    -------------------------------------------------------------------------
    clk <= not clk after 10 ns;

    -------------------------------------------------------------------------
    -- ПІДКЛЮЧЕННЯ TX
    -------------------------------------------------------------------------
    U_TX: entity work.i2c_master_tx
        port map (
            clk      => clk,
            rst      => rst,
            start_tx => start_tx,
            data_in  => data_in,
            scl      => scl_tx,
            sda      => sda_tx,
            tx_done  => tx_done,
            ack_in   => ack_in
        );

    -------------------------------------------------------------------------
    -- ПІДКЛЮЧЕННЯ RX
    -- Зауваження: твій RX не використовує scl, але ми виводимо scl_rx для
    -- можливого майбутнього розширення.
    -------------------------------------------------------------------------
    U_RX: entity work.i2c_master_rx
        port map (
            clk      => clk,
            rst      => rst,
            start_rx => start_rx,
            scl      => scl_rx,
            sda      => sda_rx,
            rx_data  => rx_data,
            rx_done  => rx_done
        );

    -------------------------------------------------------------------------
    -- СТИМУЛИ
    -------------------------------------------------------------------------
    stim_proc : process
        constant RX_BYTE : std_logic_vector(7 downto 0) := "01011001";
        variable i       : integer;
    begin
        ---------------------------------------------------------------------
        -- RESET
        ---------------------------------------------------------------------
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 50 ns;

        ---------------------------------------------------------------------
        -- ТЕСТ TX: передати 10101010 з ACK=0
        ---------------------------------------------------------------------
        data_in <= "10101010";
        ack_in  <= '0';          -- завжди ACK

        start_tx <= '1';
        wait until rising_edge(clk);
        start_tx <= '0';

        wait until tx_done = '1';
        wait for 5*20 ns;        -- трохи часу після завершення

        ---------------------------------------------------------------------
        -- ТЕСТ RX: подати байт RX_BYTE на sda_rx по одному біту за такт
        ---------------------------------------------------------------------
        start_rx <= '1';
        wait until rising_edge(clk);
        start_rx <= '0';

        -- RX у стані RECV_BIT кожен такт читає SDA у data_reg(7..0),
        -- тому просто подаємо MSB→LSB на 8 наступних фронтів clk.
        for i in 0 to 7 loop
            sda_rx <= RX_BYTE(7 - i);
            wait until rising_edge(clk);
        end loop;

        -- після 8 бітів RX переходить до STOP/DONE і піднімає rx_done
        wait until rx_done = '1';
        wait for 20 ns;

        -- Перевірка: rx_data == RX_BYTE
        if rx_data = RX_BYTE then
            report "RX OK: received " severity note;
        else
            report "RX FAIL: expected 01011001, got " severity error;
        end if;

        ---------------------------------------------------------------------
        -- КІНЕЦЬ СИМУЛЯЦІЇ
        ---------------------------------------------------------------------
        wait for 500 ns;
        report "SIM DONE" severity note;
        wait;
    end process;

end architecture;
