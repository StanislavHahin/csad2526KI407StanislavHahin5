library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2c_master_rx is
    port (
        clk      : in  std_logic;                    -- системний такт
        rst      : in  std_logic;                    -- скидання
        start_rx : in  std_logic;                    -- команда на прийом
        scl      : out std_logic;                    -- SCL (master генерує)
        sda      : in  std_logic;                    -- SDA як вхід
        rx_data  : out std_logic_vector(7 downto 0); -- прийнятий байт
        rx_done  : out std_logic                     -- "байт готовий"
    );
end entity;

architecture Behavioral of i2c_master_rx is

    type state_t is (IDLE, START, RECV_BIT, STOP, DONE);
    signal state    : state_t := IDLE;

    signal scl_reg  : std_logic := '1';
    signal bit_cnt  : unsigned(2 downto 0) := (others => '0');
    signal data_reg : std_logic_vector(7 downto 0) := (others => '0');

begin

    scl <= scl_reg;
    rx_data <= data_reg;

    process(clk, rst)
    begin
        if rst = '1' then
            state    <= IDLE;
            scl_reg  <= '1';
            bit_cnt  <= (others => '0');
            data_reg <= (others => '0');
            rx_done  <= '0';

        elsif rising_edge(clk) then
            rx_done <= '0';  -- за замовчуванням

            case state is
                when IDLE =>
                    scl_reg <= '1';
                    if start_rx = '1' then
                        bit_cnt <= (others => '0');
                        state   <= START;
                    end if;

                when START =>
                    -- тут мала б формуватись умова START, спрощуємо
                    state <= RECV_BIT;

                when RECV_BIT =>
                    -- спрощено: на кожен такт "зчитуємо" біт SDA
                    data_reg(7 - to_integer(bit_cnt)) <= sda;
                    if bit_cnt = 7 then
                        state <= STOP;
                    else
                        bit_cnt <= bit_cnt + 1;
                    end if;

                when STOP =>
                    -- формально STOP, тут просто завершуємо
                    state <= DONE;

                when DONE =>
                    rx_done <= '1';
                    state   <= IDLE;

            end case;
        end if;
    end process;

end architecture;
