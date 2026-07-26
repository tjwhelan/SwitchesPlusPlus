-- SWITCHES PLUS (a peripheral for SCOMP)
-- ECE2031 Project
-- Jason, Tyler, Ethan, Rohan
LIBRARY IEEE;
LIBRARY LPM;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE LPM.LPM_COMPONENTS.ALL;
ENTITY SWITCHES_PLUS IS
  PORT(
    CLK         : IN    STD_LOGIC;
    IO_ADDR     : IN    STD_LOGIC_VECTOR(10 DOWNTO 0);
    IO_READ     : IN    STD_LOGIC;
    IO_WRITE    : IN    STD_LOGIC;
    IO_DATA     : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    SWITCHES    : IN    STD_LOGIC_VECTOR(9 DOWNTO 0); -- for the 10 switches
    RESETN      : IN    STD_LOGIC
  );
END SWITCHES_PLUS;

ARCHITECTURE a OF SWITCHES_PLUS IS
  --mode enumeration
  TYPE MODE_TYPE IS (m_bit_def,
                     m_bit_inv,
                     m_pop_high,
                     m_pop_low,
                     m_change_mask,
                     m_change_num,
                     m_password_read,
                     m_password_write,
                     m_sim_snapsave,
                     m_sim_softsave,
                     m_sim_status,
                     m_filo_en,
                     m_filo_read,
                     m_filo_status,
                     invalid);
  --signal that tracks mode
  SIGNAL mode : MODE_TYPE;
  SIGNAL mode_helper: STD_LOGIC_VECTOR(11 DOWNTO 0); -- MSB is R/W, rest is IO_ADDR
  
  --Register for switches input (exists to support simulation)
  SIGNAL switches_input    : STD_LOGIC_VECTOR(9 DOWNTO 0);

  -- Registers for modes
  SIGNAL sim_status        : STD_LOGIC; --simulation active or not
  SIGNAL filo_enabled      : STD_LOGIC; --filo enabled or not
  SIGNAL count_high        : STD_LOGIC_VECTOR(3 DOWNTO 0); --population mode: stores # of switches high
  SIGNAL count_low         : STD_LOGIC_VECTOR(3 DOWNTO 0); --population mode: stores # of switches low
  SIGNAL last_read_reg     : STD_LOGIC_VECTOR(9 DOWNTO 0); --change mode: stores most recent read
  SIGNAL difference_mask   : STD_LOGIC_VECTOR(9 DOWNTO 0); --change mode: stores bitmask of differences from last read
  SIGNAL difference_amt    : STD_LOGIC_VECTOR(3 DOWNTO 0); --change mode: stores # of differences from last read
  SIGNAL password_reg      : STD_LOGIC_VECTOR(9 DOWNTO 0); --password mode: register that holds password
  SIGNAL password_correct  : STD_LOGIC; -- password mode: signal that is 1 if attempt correct, 0 if not
  SIGNAL saved_sim         : STD_LOGIC_VECTOR(9 DOWNTO 0); --simulation mode: bitmask saved to be used

  BEGIN

    --defining signals
    switches_input <= saved_sim WHEN sim_status = '1' else SWITCHES; 
    difference_mask <= switches_input XOR last_read_reg;
    mode_helper <= IO_READ & IO_ADDR;

    --mode assignments that allow the same address to be written to and read from
    WITH mode_helper SELECT
        mode <= m_bit_def        WHEN "100001100000",
                m_bit_inv        WHEN "100001100001",
                m_pop_high       WHEN "100001100010",
                m_pop_low        WHEN "100001100011",
                m_change_mask    WHEN "100001100100",
                m_change_num     WHEN "100001100101",
                m_password_read  WHEN "100001100110",
                m_password_write WHEN "000001100110", --write
                m_sim_snapsave   WHEN "000001100111", --write
                m_sim_softsave   WHEN "000001101000", --write
                m_sim_status     WHEN "100001101001",
                m_filo_en        WHEN "000001101010", --write
                m_filo_read      WHEN "000001101011", --write
                m_filo_status    WHEN "100001101100",
                invalid          WHEN OTHERS;

    --combinational logic calculations
    PROCESS(switches_input, difference_mask, password_reg)
      VARIABLE pop_temp_count    : INTEGER RANGE 0 TO 10;
      VARIABLE change_temp_count : INTEGER RANGE 0 TO 10;
    BEGIN
        --population mode calculations
        pop_temp_count := 0;
        FOR i IN 0 TO 9 LOOP
            IF switches_input(i) = '1' THEN
                pop_temp_count := pop_temp_count + 1;
            END IF;
        END LOOP;
        count_high <= CONV_STD_LOGIC_VECTOR(pop_temp_count, 4);

        --change mode calculations
        change_temp_count := 0;
        FOR i IN 0 TO 9 LOOP
            IF difference_mask(i) = '1' THEN
                change_temp_count := change_temp_count + 1;
            END IF;
        END LOOP;
        difference_amt <= CONV_STD_LOGIC_VECTOR(change_temp_count, 4);

        --password mode calculations
        IF password_reg = switches_input THEN
            password_correct <= '1';
        ELSE
            password_correct <= '0';
        END IF;
    END PROCESS;
    count_low <= "1010" - count_high; -- 10 minus # of high switches

    --reset and sequential logic features
    PROCESS(RESETN, CLK)
    BEGIN
        IF (RESETN = '0') THEN
            --resets all concurrent registers (exist over multiple reads)
            last_read_reg <= "0000000000";
            password_reg  <= "0000000000";
            saved_sim     <= "0000000000";
            sim_status    <= '0';
        ELSIF (RISING_EDGE(CLK)) THEN
            IF (IO_READ = '1') THEN
                IF (mode /= m_change_mask AND mode /= m_change_num) THEN
                    last_read_reg <= switches_input;
                    IF (sim_status = '1' AND mode /= m_sim_status) THEN
                        sim_status <= '0';
                    END IF;
                END IF;
            ELSIF (IO_WRITE = '1') THEN
                CASE mode is
                    WHEN m_password_write =>
                        password_reg <= switches_input;
                    WHEN m_sim_snapsave =>
                        saved_sim <= switches_input;
                        sim_status <= '1';
                    WHEN m_sim_softsave =>
                        saved_sim <= IO_DATA(9 DOWNTO 0);
                        sim_status <= '1';
                    WHEN OTHERS =>
                        NULL;
                END CASE;
            END IF;
        END IF;
    END PROCESS;
    
    WITH mode SELECT
        IO_DATA <=
            "000000" & switches_input                     WHEN m_bit_def,  -- bit_def: default switch bitmask
            "000000" & (NOT switches_input)               WHEN m_bit_inv,  -- bit_inv: inverted switch bitmask
            "000000000000" & count_high                   WHEN m_pop_high, -- pop_high: count of active-high switches
            "000000000000" & count_low                    WHEN m_pop_low, -- pop_low: count of active-low switches
            "000000" & difference_mask                    WHEN m_change_mask, --change_mask
            "000000000000" & difference_amt               WHEN m_change_num, --change_num
            "000000000000000" & password_correct          WHEN m_password_read, --password_read
            "000000000000000" & sim_status                WHEN m_sim_status, --sim_status           
            "ZZZZZZZZZZZZZZZZ"                            WHEN OTHERS;
        
END a;
