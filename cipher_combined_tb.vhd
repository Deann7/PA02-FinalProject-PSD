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
        file input_file : text;
        file output_file : text;
        file temp_file : text;
        variable line_in, line_out : line;
        variable char_in : character;
        variable result : STD_LOGIC_VECTOR(7 downto 0);
        variable temp_char : character;
        variable line_count : integer := 0;
    begin
        -- Initialize files
        file_open(input_file, "input_text.txt", read_mode);
        file_open(output_file, "output_text.txt", write_mode);
        file_open(temp_file, "temp.txt", write_mode);

        -- Reset sequence
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;

        -- Mode 00 - Process first string until blank line
        mode <= "00";
        write(line_out, string'("Mode 00 - Case 1 Encrypt:"));
        writeline(output_file, line_out);
        
        while not endfile(input_file) loop
            readline(input_file, line_in);
            if line_in.all'length = 0 then
                exit;
            end if;
            read(line_in, char_in);
            
            -- Process character
            input_char <= std_logic_vector(to_unsigned(character'pos(char_in), 8));
            wait until rising_edge(clk);
            start <= '1';
            wait until rising_edge(clk);
            start <= '0';
            
            -- Wait for done and capture output
            wait until done = '1';
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            result := output_char;
            
            -- Write to both output and temp files
            write(line_out, character'val(to_integer(unsigned(result))));
            writeline(output_file, line_out);
            write(line_out, character'val(to_integer(unsigned(result))));
            writeline(temp_file, line_out);
            
            line_count := line_count + 1;
            
            wait until rising_edge(clk);
            wait until rising_edge(clk);
        end loop;

        -- Mode 01 - Read from temp file
        file_close(temp_file);
        file_open(temp_file, "temp.txt", read_mode);
        
        mode <= "01";
        write(line_out, string'("Mode 01 - Case 1 Decrypt:"));
        writeline(output_file, line_out);
        
        for i in 1 to line_count loop
            readline(temp_file, line_in);
            read(line_in, char_in);
            
            input_char <= std_logic_vector(to_unsigned(character'pos(char_in), 8));
            wait until rising_edge(clk);
            start <= '1';
            wait until rising_edge(clk);
            start <= '0';
            
            wait until done = '1';
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            result := output_char;
            
            write(line_out, character'val(to_integer(unsigned(result))));
            writeline(output_file, line_out);
            
            wait until rising_edge(clk);
            wait until rising_edge(clk);
        end loop;

        -- Mode 10 - Process second string until blank line
        line_count := 0;
        file_close(temp_file);
        file_open(temp_file, "temp.txt", write_mode);
        
        mode <= "10";
        write(line_out, string'("Mode 10 - Case 2 Encrypt:"));
        writeline(output_file, line_out);
        
        while not endfile(input_file) loop
            readline(input_file, line_in);
            if line_in.all'length = 0 then
                exit;
            end if;
            read(line_in, char_in);
            
            input_char <= std_logic_vector(to_unsigned(character'pos(char_in), 8));
            wait until rising_edge(clk);
            start <= '1';
            wait until rising_edge(clk);
            start <= '0';
            
            wait until done = '1';
            wait until done = '0';
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            result := output_char;
            
            write(line_out, character'val(to_integer(unsigned(result))));
            writeline(output_file, line_out);
            write(line_out, character'val(to_integer(unsigned(result))));
            writeline(temp_file, line_out);
            
            line_count := line_count + 1;
            
            wait until rising_edge(clk);
            wait until rising_edge(clk);
        end loop;

        -- Mode 11 - Read from temp file
        file_close(temp_file);
        file_open(temp_file, "temp.txt", read_mode);
        
        mode <= "11";
        write(line_out, string'("Mode 11 - Case 2 Decrypt:"));
        writeline(output_file, line_out);
        
        for i in 1 to line_count loop
            readline(temp_file, line_in);
            read(line_in, char_in);
            
            input_char <= std_logic_vector(to_unsigned(character'pos(char_in), 8));
            wait until rising_edge(clk);
            start <= '1';
            wait until rising_edge(clk);
            start <= '0';
            
            wait until done = '1';
            wait until done = '0';
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            result := output_char;
            
            write(line_out, character'val(to_integer(unsigned(result))));
            writeline(output_file, line_out);
            
            wait until rising_edge(clk);
            wait until rising_edge(clk);
        end loop;

        -- Close files
        file_close(input_file);
        file_close(output_file);
        file_close(temp_file);
        
        wait;
    end process;
end behavior;