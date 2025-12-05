library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Testbench для верифікації I2C master Tx/Rx
entity tb_i2c is
end entity;

architecture sim of tb_i2c is

    -- Системний тактовий сигнал і скидання
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';

    -- Інтерфейс передавача (Tx)
    signal start_tx  : std_logic := '0';
    signal data_in   : std_logic_vector(7 downto 0) := (others => '0');
    signal scl_tx    : std_logic;
    signal sda_tx    : std_logic := 'Z';
    signal tx_done   : std_logic;
    signal ack_in    : std_logic := '1';

    -- Інтерфейс приймача (Rx)
    signal start_rx  : std_logic := '0';
    signal scl_rx    : std_logic;
    signal sda_rx    : std_logic := '1';
    signal rx_data   : std_logic_vector(7 downto 0);
    signal rx_done   : std_logic;

begin

    -- Генерація системного такту 50 МГц (період 20 нс)
    clk <= not clk after 10 ns;

    -- Інстанціювання модуля передавача I2C
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

    -- Інстанціювання модуля приймача I2C
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

    -- Основний процес стимулів для Tx і Rx
    stim_proc : process
        constant RX_BYTE : std_logic_vector(7 downto 0) := "01011001";  -- тестовий байт для Rx
        variable i       : integer;
    begin
        -- Ініціалізація та скидання
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 50 ns;

        -- Тест передавача: передаємо 10101010 з постійним ACK=0
        data_in <= "10101010";
        ack_in  <= '0';

        start_tx <= '1';
        wait until rising_edge(clk);
        start_tx <= '0';

        wait until tx_done = '1';
        wait for 5*20 ns;        -- пауза після завершення передачі

        -- Тест приймача: подаємо RX_BYTE по одному біту за такт (MSB→LSB)
        start_rx <= '1';
        wait until rising_edge(clk);
        start_rx <= '0';

        for i in 0 to 7 loop
            sda_rx <= RX_BYTE(7 - i);
            wait until rising_edge(clk);
        end loop;

        -- Очікуємо сигнал завершення прийому
        wait until rx_done = '1';
        wait for 20 ns;

        -- Проста перевірка коректності прийнятих даних
        if rx_data = RX_BYTE then
            report "RX OK: received expected byte" severity note;
        else
            report "RX FAIL: expected 01011001, got different value" severity error;
        end if;

        -- Завершення симуляції
        wait for 500 ns;
        report "SIM DONE" severity note;
        wait;
    end process;

end architecture;
