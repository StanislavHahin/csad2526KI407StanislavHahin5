-- I2C Master Transmitter (Tx)
-- Варіант 5: I2C, VHDL

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2c_master_tx is
    port (
        clk      : in  std_logic;              -- системний тактовий сигнал
        rst      : in  std_logic;              -- асинхронний скидання
        start_tx : in  std_logic;              -- команда на старт передачі
        data_in  : in  std_logic_vector(7 downto 0); -- байт даних / адреси
        scl      : out std_logic;              -- лінія SCL (master генерує)
        sda      : inout std_logic;            -- лінія SDA (двоспрямована)
        tx_done  : out std_logic;              -- прапор завершення передачі
        ack_in   : in  std_logic               -- зразок ACK від slave (опц.)
    );
end entity;

architecture Behavioral of i2c_master_tx is

    type state_t is (IDLE, START, SEND_BIT, RECV_ACK, NEXT_BYTE, STOP, DONE);
    signal state    : state_t := IDLE;

    signal tx_reg   : std_logic_vector(7 downto 0) := (others => '0'); -- регістр даних
    signal bit_cnt  : unsigned(2 downto 0) := (others => '0');         -- лічильник 0..7

    signal scl_reg  : std_logic := '1';  -- внутрішній SCL
    signal sda_out  : std_logic := '1';  -- те, що master виставляє на SDA
    signal sda_oe   : std_logic := '0';  -- 1 = ведемо SDA, 0 = відпускаємо

begin

    -- виводи
    scl <= scl_reg;
    sda <= sda_out when sda_oe = '1' else 'Z';  -- трістан для ACK від slave

    process(clk, rst)
    begin
        if rst = '1' then
            state   <= IDLE;
            scl_reg <= '1';
            sda_out <= '1';
            sda_oe  <= '0';
            tx_done <= '0';
            bit_cnt <= (others => '0');
            tx_reg  <= (others => '0');

        elsif rising_edge(clk) then
            tx_done <= '0';  -- за замовчуванням

            case state is

                when IDLE =>
                    scl_reg <= '1';
                    sda_out <= '1';
                    sda_oe  <= '1';
                    if start_tx = '1' then
                        tx_reg  <= data_in;        -- завантажуємо байт
                        bit_cnt <= (others => '0');
                        state   <= START;
                    end if;

                when START =>
                    -- SCL = 1, SDA = 0 → умова START
                    scl_reg <= '1';
                    sda_out <= '0';
                    sda_oe  <= '1';
                    state   <= SEND_BIT;

                when SEND_BIT =>
                    -- виставляємо поточний біт
                    sda_out <= tx_reg(7 - to_integer(bit_cnt));
                    sda_oe  <= '1';
                    -- тут повинна бути логіка тактування scl_reg (scl_tick)
                    if bit_cnt = 7 then
                        state <= RECV_ACK;
                    else
                        bit_cnt <= bit_cnt + 1;
                    end if;

                when RECV_ACK =>
                    -- відпускаємо SDA і читаємо ACK
                    sda_oe <= '0';
                    -- ack_in = 0 → ACK
                    if ack_in = '0' then
                        state <= NEXT_BYTE;
                    else
                        state <= STOP;
                    end if;

                when NEXT_BYTE =>
                    -- поки що вважаємо, що більше байтів немає
                    state <= STOP;

                when STOP =>
                    -- STOP: SDA з 0 у 1 при SCL = 1
                    scl_reg <= '1';
                    sda_out <= '1';
                    sda_oe  <= '1';
                    state   <= DONE;

                when DONE =>
                    tx_done <= '1';
                    state   <= IDLE;

            end case;
        end if;
    end process;

end architecture;
