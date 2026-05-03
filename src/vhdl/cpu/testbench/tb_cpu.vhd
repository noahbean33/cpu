library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.cpu_pkg.all;

entity tb_cpu is
  generic (
    TEST        : string  := "addi";
    MAX_CYCLES  : natural := 200000
  );
end entity;

architecture sim of tb_cpu is

function reg_name(r : std_logic_vector(4 downto 0)) return string is
begin
    return "x" & integer'image(to_integer(unsigned(r)));
end function;

function dump_registers(regs : REGISTER_ARRAY_t) return string is
    variable linebuf : line;
    variable any_nonzero : boolean := false;
begin
    for i in regs'range loop
        if regs(i) /= x"00000000" then
            any_nonzero := true;
            exit;
        end if;
    end loop;
    if not any_nonzero then
        return "";
    end if;
    write(linebuf, string'("[REGS] "));
    for i in regs'range loop
        if regs(i) /= x"00000000" then
            write(linebuf, string'("x"));
            write(linebuf, i);
            write(linebuf, string'("="));
            write(linebuf, to_hstring(regs(i)));
            write(linebuf, string'(" "));
        end if;
    end loop;
    return linebuf.all;
end function;

function to_mnemonic(instr : std_logic_vector(31 downto 0)) return string is
    variable opc  : std_logic_vector(6 downto 0) := instr(6 downto 0);
    variable f3   : std_logic_vector(2 downto 0) := instr(14 downto 12);
    variable f7   : std_logic_vector(6 downto 0) := instr(31 downto 25);

    variable rd   : std_logic_vector(4 downto 0) := instr(11 downto 7);
    variable rs1  : std_logic_vector(4 downto 0) := instr(19 downto 15);
    variable rs2  : std_logic_vector(4 downto 0) := instr(24 downto 20);

    variable slv_imm_i : std_logic_vector(31 downto 0) := (31 downto 11 => instr(31)) & instr(30 downto 20);
    variable slv_imm_s : std_logic_vector(31 downto 0) := (31 downto 11 => instr(31)) & instr(30 downto 25) & instr(11 downto 7);
    variable slv_imm_b : std_logic_vector(31 downto 0) := (31 downto 12 => instr(31)) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0';
    variable slv_imm_u : std_logic_vector(31 downto 0) := instr(31 downto 12) & (11 downto 0 => '0');
    variable slv_imm_j : std_logic_vector(31 downto 0) := (31 downto 20 => instr(31)) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0';

begin
    --------------------------------------------------------------------
    -- LUI / AUIPC
    --------------------------------------------------------------------
    if opc = "0110111" then
        return "lui " & reg_name(rd) & ", " & to_hstring(slv_imm_u);
    elsif opc = "0010111" then
        return "auipc " & reg_name(rd) & ", " & to_hstring(slv_imm_u);

    --------------------------------------------------------------------
    -- Jumps
    --------------------------------------------------------------------
    elsif opc = "1101111" then
        return "jal " & reg_name(rd) & ", " & to_hstring(slv_imm_j);
    elsif opc = "1100111" and f3 = "000" then
        return "jalr " & reg_name(rd) & ", " &
               to_hstring(slv_imm_i) & "(" & reg_name(rs1) & ")";

    --------------------------------------------------------------------
    -- Branch
    --------------------------------------------------------------------
    elsif opc = "1100011" then
        case f3 is
            when "000" => return "beq "  & reg_name(rs1) & ", " & reg_name(rs2) & ", " & to_hstring(slv_imm_b);
            when "001" => return "bne "  & reg_name(rs1) & ", " & reg_name(rs2) & ", " & to_hstring(slv_imm_b);
            when "100" => return "blt "  & reg_name(rs1) & ", " & reg_name(rs2) & ", " & to_hstring(slv_imm_b);
            when "101" => return "bge "  & reg_name(rs1) & ", " & reg_name(rs2) & ", " & to_hstring(slv_imm_b);
            when "110" => return "bltu " & reg_name(rs1) & ", " & reg_name(rs2) & ", " & to_hstring(slv_imm_b);
            when "111" => return "bgeu " & reg_name(rs1) & ", " & reg_name(rs2) & ", " & to_hstring(slv_imm_b);
            when others => return "branch?";
        end case;

    --------------------------------------------------------------------
    -- Loads
    --------------------------------------------------------------------
    elsif opc = "0000011" then
        case f3 is
            when "000" => return "lb "  & reg_name(rd) & ", " & to_hstring(slv_imm_i) & "(" & reg_name(rs1) & ")";
            when "001" => return "lh "  & reg_name(rd) & ", " & to_hstring(slv_imm_i) & "(" & reg_name(rs1) & ")";
            when "010" => return "lw "  & reg_name(rd) & ", " & to_hstring(slv_imm_i) & "(" & reg_name(rs1) & ")";
            when "100" => return "lbu " & reg_name(rd) & ", " & to_hstring(slv_imm_i) & "(" & reg_name(rs1) & ")";
            when "101" => return "lhu " & reg_name(rd) & ", " & to_hstring(slv_imm_i) & "(" & reg_name(rs1) & ")";
            when others => return "load?";
        end case;

    --------------------------------------------------------------------
    -- Stores
    --------------------------------------------------------------------
    elsif opc = "0100011" then
        case f3 is
            when "000" => return "sb " & reg_name(rs2) & ", " & to_hstring(slv_imm_s) & "(" & reg_name(rs1) & ")";
            when "001" => return "sh " & reg_name(rs2) & ", " & to_hstring(slv_imm_s) & "(" & reg_name(rs1) & ")";
            when "010" => return "sw " & reg_name(rs2) & ", " & to_hstring(slv_imm_s) & "(" & reg_name(rs1) & ")";
            when others => return "store?";
        end case;

    --------------------------------------------------------------------
    -- OP-IMM (ADDI, ANDI, ORI…)
    --------------------------------------------------------------------
    elsif opc = "0010011" then
        case f3 is
            when "000" => return "addi "  & reg_name(rd) & ", " & reg_name(rs1) & ", " & to_hstring(slv_imm_i);
            when "010" => return "slti "  & reg_name(rd) & ", " & reg_name(rs1) & ", " & to_hstring(slv_imm_i);
            when "011" => return "sltiu " & reg_name(rd) & ", " & reg_name(rs1) & ", " & to_hstring(slv_imm_i);
            when "100" => return "xori "  & reg_name(rd) & ", " & reg_name(rs1) & ", " & to_hstring(slv_imm_i);
            when "110" => return "ori  "  & reg_name(rd) & ", " & reg_name(rs1) & ", " & to_hstring(slv_imm_i);
            when "111" => return "andi "  & reg_name(rd) & ", " & reg_name(rs1) & ", " & to_hstring(slv_imm_i);
            when "001" => return "slli "  & reg_name(rd) & ", " & reg_name(rs1) & ", " & to_hstring(instr(24 downto 20));
            when "101" =>
                if f7 = "0000000" then
                    return "srli " & reg_name(rd) & ", " & reg_name(rs1) & ", " &
                           integer'image(to_integer(unsigned(instr(24 downto 20))));
                else
                    return "srai " & reg_name(rd) & ", " & reg_name(rs1) & ", " &
                           integer'image(to_integer(unsigned(instr(24 downto 20))));
                end if;
            when others => return "op-imm?";
        end case;

    --------------------------------------------------------------------
    -- OP (register-register)
    --------------------------------------------------------------------
    elsif opc = "0110011" then
        case f3 is
            when "000" =>
                if f7 = "0000000" then return "add " & reg_name(rd) & ", " & reg_name(rs1) & ", " & reg_name(rs2);
                else return "sub " & reg_name(rd) & ", " & reg_name(rs1) & ", " & reg_name(rs2);
                end if;
            when "001" => return "sll "  & reg_name(rd) & ", " & reg_name(rs1) & ", " & reg_name(rs2);
            when "010" => return "slt "  & reg_name(rd) & ", " & reg_name(rs1) & ", " & reg_name(rs2);
            when "011" => return "sltu " & reg_name(rd) & ", " & reg_name(rs1) & ", " & reg_name(rs2);
            when "100" => return "xor "  & reg_name(rd) & ", " & reg_name(rs1) & ", " & reg_name(rs2);
            when "101" =>
                if f7 = "0000000" then return "srl " & reg_name(rd) & ", " & reg_name(rs1) & ", " & reg_name(rs2);
                else return "sra " & reg_name(rd) & ", " & reg_name(rs1) & ", " & reg_name(rs2);
                end if;
            when "110" => return "or "   & reg_name(rd) & ", " & reg_name(rs1) & ", " & reg_name(rs2);
            when "111" => return "and "  & reg_name(rd) & ", " & reg_name(rs1) & ", " & reg_name(rs2);
            when others => return "op?";
        end case;

    --------------------------------------------------------------------
    -- SYSTEM
    --------------------------------------------------------------------
    elsif opc = "1110011" then
        if instr(31 downto 20) = x"000" then return "ecall";
        elsif instr(31 downto 20) = x"001" then return "ebreak";
        else return "system?";
        end if;

    end if;

    --------------------------------------------------------------------
    -- DEFAULT
    --------------------------------------------------------------------
    return "unknown";

end function;


  --------------------------------------------------------------------
  -- DUT interface
  --------------------------------------------------------------------
  signal clk                : std_logic := '0';
  signal resetn            : std_logic := '0';

  -- Instruction memory port
  signal imem_ready         : std_logic;
  signal imem_valid         : std_logic;
  signal imem_addr          : std_logic_vector(31 downto 0);
  signal imem_rdata         : std_logic_vector(31 downto 0);
  signal imem_ready_d       : std_logic;
  signal imem_valid_d       : std_logic;
  signal imem_addr_d        : std_logic_vector(31 downto 0);
  signal imem_rdata_d       : std_logic_vector(31 downto 0);

  signal regs               : REGISTER_ARRAY_t;

  -- Data memory port
  signal dmem_ready_d       : std_logic;
  signal dmem_valid_d       : std_logic;
  signal dmem_addr_d        : std_logic_vector(31 downto 0);
  signal dmem_wdata_d       : std_logic_vector(31 downto 0);
  signal dmem_rdata_d       : std_logic_vector(31 downto 0);
  signal dmem_ready         : std_logic;
  signal dmem_valid         : std_logic;
  signal dmem_addr          : std_logic_vector(31 downto 0);
  signal dmem_wdata         : std_logic_vector(31 downto 0);
  signal dmem_rdata         : std_logic_vector(31 downto 0);
  signal dmem_we            : std_logic;
  signal dmem_access_width  : MEM_ACCESS_WIDTH_t;

  signal cycles             : natural := 0;

  constant EBREAK           : std_logic_vector(31 downto 0) := x"00100073";

begin
  --------------------------------------------------------------------
  -- 100 MHz clock
  --------------------------------------------------------------------
  clk <= not clk after 5 ns;

  --------------------------------------------------------------------
  -- Reset pulse
  --------------------------------------------------------------------
  process
  begin
    resetn <= '0';
    wait for 200 ns;
    resetn <= '1';
    wait;
  end process;

  imem_ready <= '1';
  dmem_ready <= '1';

  --------------------------------------------------------------------
  -- DUT
  --------------------------------------------------------------------
  dut: entity work.cpu
    port map (
      clk                => clk,
      resetn             => resetn,

      -- Instruction port
      imem_ready         => imem_ready,
      imem_valid         => imem_valid,
      imem_addr          => imem_addr,
      imem_rdata         => imem_rdata,

      -- Data port
      dmem_ready         => dmem_ready,
      dmem_valid         => dmem_valid,
      dmem_addr          => dmem_addr,
      dmem_wdata         => dmem_wdata,
      dmem_write_enable  => dmem_we,
      dmem_access_width  => dmem_access_width,
      dmem_rdata         => dmem_rdata,

      -- Debug registers
      trace_regs         => regs
    );

  --------------------------------------------------------------------
  -- Instruction ROM (Harvard instruction side)
  --------------------------------------------------------------------
  inst_mem: entity work.inst_memory
    port map (
      addr               => imem_addr,
      en                 => '1',
      data               => imem_rdata
    );

  --------------------------------------------------------------------
  -- Data RAM (Harvard data side)
  --------------------------------------------------------------------
  data_mem : entity work.data_memory
    port map (
      clk                => clk,
      addr               => dmem_addr,
      write_enable       => dmem_we,
      access_width       => dmem_access_width,
      access_enable      => dmem_valid,
      rdata              => dmem_rdata,
      wdata              => dmem_wdata
    );
  --------------------------------------------------------------------
  -- Monitor for PASS/FAIL via semihosting EBREAK
  --------------------------------------------------------------------
  monitor: process(clk)
  begin
    if rising_edge(clk) then
      if resetn = '1' then
        cycles <= cycles + 1;

        imem_ready_d <= imem_ready;
        imem_valid_d <= imem_valid;
        imem_rdata_d <= imem_rdata;
        imem_addr_d  <= imem_addr;
        dmem_ready_d <= dmem_ready;
        dmem_valid_d <= dmem_valid;
        dmem_addr_d  <= dmem_addr;
        dmem_wdata_d <= dmem_wdata;
        dmem_rdata_d <= dmem_rdata;

        if imem_ready_d = '1' and imem_valid_d = '1' then
            report "[INST] Addr="        & to_hstring(imem_addr_d) &
                  ", Word="       & integer'image(to_integer(unsigned(imem_addr_d)/4)) &
                  ", Instuction=" & to_hstring(imem_rdata_d) &
                  ", Mnemonic="   & to_mnemonic(imem_rdata_d);
            if dump_registers(regs) /= "" then
              report dump_registers(regs) severity note;
            end if;
        end if;

        if dmem_ready_d = '1' and dmem_valid_d = '1' then
            report "[DATA] Addr="      & to_hstring(dmem_addr_d) &
                  ", Word="       & integer'image(to_integer(unsigned(dmem_addr_d)/4)) &
                  ", WData="      & to_hstring(dmem_wdata_d) &
                  ", RData="      & to_hstring(dmem_rdata_d);
        end if;

        -- Detect EBREAK on instruction fetch
        if imem_valid_d = '1' and imem_ready_d = '1' and imem_rdata_d = EBREAK then
          if regs(10) = x"00000101" then
            report "RVTEST (" & TEST & ") : OK" severity note;
            std.env.stop(0);
          elsif regs(10) = x"00000102" then
            report "RVTEST (" & TEST & ") : KO" severity note;
            report "TEST_" & integer'image(to_integer(unsigned(regs(11)))) & " is KO" severity failure;
            std.env.stop(1);
          else
            report "Semihosting EBREAK unexpected x10=0x" & to_hstring(regs(10)) severity failure;
            std.env.stop(1);
          end if;
        end if;

        if cycles >= MAX_CYCLES then
          report "Timeout after " & integer'image(MAX_CYCLES) & " cycles" severity failure;
          std.env.stop(1);
        end if;
      end if;
    end if;
  end process;

end architecture;
