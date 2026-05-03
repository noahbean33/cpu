library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;
use std.env.all;

entity testbench is
end entity;

architecture tb of testbench is

  constant TIMEOUT         : integer := 100000;
  signal clk               : std_logic := '0';
  signal resetn            : std_logic := '1';
  signal leds              : std_logic_vector(7 downto 0);
  signal ser_rx            : std_logic := '1'; -- idle high
  signal ser_tx            : std_logic;
  constant ser_half_period : time := 26.041666 us;
  signal cycle_cnt         : integer := 0;

  -- Helper: convert std_logic to printable '0'/'1'/'X'...
  function sl_to_char(s : std_logic) return character is
  begin
    return std_logic'image(s)(2); -- image is like "'0'", take the 2nd char
  end function;

  procedure uart_getc(signal s : in std_logic; variable ch : out std_logic_vector(7 downto 0)) is
  begin
    ch := (others => '0');
    -- Wait for start bit (falling edge)
    wait until (s'event and s = '0');
    -- Move to middle of start bit
    wait for ser_half_period;
    -- Sample 8 data bits (LSB first), each bit is 2*half_period
    for i in 0 to 7 loop
      wait for 2 * ser_half_period;
      ch(i) := s;
    end loop;
    -- Stop bit time
    wait for 2 * ser_half_period;
  end procedure;

begin

  p_clk : process
  begin
    clk <= '0';
    wait for 50 ns;
    clk <= '1';
    wait for 50 ns;
  end process;

  resetn <= '0', '1' after 100 ns;

  -- Cycle counter
  p_cycle_cnt : process(clk)
  begin
    if rising_edge(clk) then
      cycle_cnt <= cycle_cnt + 1;
    end if;
  end process;

  -- LED monitor
  p_led_monitor : process
    variable L : line;
  begin
    wait on leds;
    wait for 1 ns;
    write(L, string'("["));
    write(L, now);
    write(L, string'("] LEDs="));
    -- Print leds(7 downto 0) as 8-bit binary
    for i in leds'range loop
      write(L, sl_to_char(leds(i)));
    end loop;
    writeline(output, L);
  end process;

  p_uart_monitor : process
    variable c    : std_logic_vector(7 downto 0);
    variable L    : line;
    variable ch_i : integer;
    variable ch   : character;
  begin
    while true loop
      uart_getc(ser_tx, c);
      ch_i := to_integer(unsigned(c));
      ch   := character'val(ch_i);
      write(L, ch);     
      writeline(output, L);   
    end loop;
  end process;

  -- Simulation control
  p_sim_ctrl : process
  begin
    for j in 1 to TIMEOUT loop
        wait until rising_edge(clk);
    end loop;
    finish;
    wait;
  end process;

  -- DUT
  uut : entity work.top
    generic map (
		g_FPGA => false
	)
    port map (
      resetn => resetn,
      clk    => clk,
      leds   => leds,
      ser_rx => ser_rx,
      ser_tx => ser_tx
    );

end architecture;
