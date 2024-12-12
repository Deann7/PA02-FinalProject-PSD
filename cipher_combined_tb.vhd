library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity cipher_combined_tb is
end cipher_combined_tb;

architecture behavior of cipher_combined_tb is
    -- Component Declaration
    component cipher_combined
        Port ( 
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            mode : in STD_LOGIC_VECTOR(1 downto 0);
            start : in STD_LOGIC;
            shift_value : in STD_LOGIC_VECTOR(4 downto 0);
            input_char : in STD_LOGIC_VECTOR(7 downto 0);
            output_char : out STD_LOGIC_VECTOR(7 downto 0);
            done : out STD_LOGIC
        );
    end component;

    -- Signals
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal mode : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal start : STD_LOGIC := '0';
    signal shift_value : STD_LOGIC_VECTOR(4 downto 0) := "00011";
    signal input_char : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal output_char : STD_LOGIC_VECTOR(7 downto 0);
    signal done : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;
    
    -- Procedure for processing a single character
    procedure process_lines(
        signal mode_sig : in STD_LOGIC_VECTOR(1 downto 0);
        signal start_sig : out STD_LOGIC;
        signal input_sig : out STD_LOGIC_VECTOR(7 downto 0);
        signal done_sig : in STD_LOGIC;
        signal output_sig : in STD_LOGIC_VECTOR(7 downto 0);
        file input_file, output_file : TEXT;
        signal clk_sig : in STD_LOGIC;
        constant start_line : in integer;
        constant end_line : in integer) is
        
        variable line_in, line_out : line;
        variable char_in : character;
        variable current_line : integer := 1;
        variable temp_line : line;
        variable result : STD_LOGIC_VECTOR(7 downto 0);  -- New variable for storing result
    begin
        -- Skip to start_line
        while current_line < start_line loop
            if not endfile(input_file) then
                readline(input_file, temp_line);
                current_line := current_line + 1;
            end if;
        end loop;
        
        -- Process lines in range
        while current_line <= end_line and not endfile(input_file) loop
            readline(input_file, line_in);
            if line_in.all'length > 0 then
                read(line_in, char_in);
                
                input_sig <= std_logic_vector(to_unsigned(character'pos(char_in), 8));
                wait until rising_edge(clk_sig);
                
                start_sig <= '1';
                wait until rising_edge(clk_sig);
                start_sig <= '0';
                
                if mode_sig = "00" or mode_sig = "01" then
                    -- Wait for done signal
                    wait until done_sig = '1';
                    -- Wait 2 clock cycles after done goes high
                    wait until rising_edge(clk_sig);
                    wait until rising_edge(clk_sig);
                    -- Capture output after 2 cycles
                    result := output_sig;
                    write(line_out, character'val(to_integer(unsigned(result))));
                    writeline(output_file, line_out);
                else
                    -- Wait for done to go high then low
                    wait until done_sig = '1';
                    wait until done_sig = '0';
                    -- Wait 2 clock cycles after done goes low
                    wait until rising_edge(clk_sig);
                    wait until rising_edge(clk_sig);
                    -- Capture output after 2 cycles
                    result := output_sig;
                    write(line_out, character'val(to_integer(unsigned(result))));
                    writeline(output_file, line_out);
                end if;
                
                -- Wait for IDLE state before next input
                wait until rising_edge(clk_sig);
                wait until rising_edge(clk_sig);
            end if;
            current_line := current_line + 1;
        end loop;
    end procedure;

begin
    -- Component instantiation
    uut: cipher_combined port map (
        clk => clk,
        reset => reset,
        mode => mode,
        start => start,
        shift_value => shift_value,
        input_char => input_char,
        output_char => output_char,
        done => done
    );

    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Main test process
    stim_proc: process
        variable line_out : line;
        file input_file : text;
        file output_file : text;
    begin
        -- Initialize files
        file_open(input_file, "input_text.txt", read_mode);
        file_open(output_file, "output_text.txt", write_mode);

        -- Reset sequence
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;

        -- Mode 00 (Case 1 Encrypt) - Lines 1-5
        mode <= "00";
        write(line_out, string'("Mode 00 - Case 1 Encrypt:"));
        writeline(output_file, line_out);
        process_lines(mode, start, input_char, done, output_char, input_file, output_file, clk, 1, 5);
        
        -- Reset file for next mode
        file_close(input_file);
        file_open(input_file, "input_text.txt", read_mode);

        -- Mode 01 (Case 1 Decrypt) - Lines 7-11
        mode <= "01";
        write(line_out, string'("Mode 01 - Case 1 Decrypt:"));
        writeline(output_file, line_out);
        process_lines(mode, start, input_char, done, output_char, input_file, output_file, clk, 7, 11);

        -- Reset file for next mode
        file_close(input_file);
        file_open(input_file, "input_text.txt", read_mode);

        -- Mode 10 (Case 2 Encrypt) - Lines 13-17
        mode <= "10";
        write(line_out, string'("Mode 10 - Case 2 Encrypt:"));
        writeline(output_file, line_out);
        process_lines(mode, start, input_char, done, output_char, input_file, output_file, clk, 13, 18);

        -- Reset file for next mode
        file_close(input_file);
        file_open(input_file, "input_text.txt", read_mode);

        -- Mode 11 (Case 2 Decrypt) - Lines 19-23
        mode <= "11";
        write(line_out, string'("Mode 11 - Case 2 Decrypt:"));
        writeline(output_file, line_out);
        process_lines(mode, start, input_char, done, output_char, input_file, output_file, clk, 19, 23);

        -- Close files
        file_close(input_file);
        file_close(output_file);
        
        wait;
    end process;
end behavior;