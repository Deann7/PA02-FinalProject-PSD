library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity cipher_combined_tb is
end cipher_combined_tb;

architecture behavior of cipher_combined_tb is
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
        variable result_str : string(1 to 80);  -- Buffer for result string
        variable str_len : integer := 0;
        variable char_in : character;
        variable result : std_logic_vector(7 downto 0);
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

        -- Mode 00 - Process first word
        mode <= "00";
        write(line_out, string'("Mode 00 - Case 1 Encrypt:"));
        writeline(output_file, line_out);
        
        -- Read and process first word
        readline(input_file, line_in);
        str_len := 0;
        
        -- Process each character in the word
        for i in 1 to line_in'length loop
            read(line_in, char_in);
            
            input_char <= std_logic_vector(to_unsigned(character'pos(char_in), 8));
            wait until rising_edge(clk);
            start <= '1';
            wait until rising_edge(clk);
            start <= '0';
            
            wait until done = '1';
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            
            -- Store encrypted character
            str_len := str_len + 1;
            result_str(str_len) := character'val(to_integer(unsigned(output_char)));
            
            wait until rising_edge(clk);
            wait until rising_edge(clk);
        end loop;
        
        -- Write complete encrypted word
        write(line_out, result_str(1 to str_len));
        writeline(output_file, line_out);
        write(line_out, result_str(1 to str_len));  -- Also write to temp file
        writeline(temp_file, line_out);

        -- Mode 01 - Decrypt first word
        mode <= "01";
        write(line_out, string'("Mode 01 - Case 1 Decrypt:"));
        writeline(output_file, line_out);
        
        -- Read encrypted word from temp file
        file_close(temp_file);
        file_open(temp_file, "temp.txt", read_mode);
        readline(temp_file, line_in);
        str_len := 0;
        
        -- Process each character
        for i in 1 to line_in'length loop
            read(line_in, char_in);
            
            input_char <= std_logic_vector(to_unsigned(character'pos(char_in), 8));
            wait until rising_edge(clk);
            start <= '1';
            wait until rising_edge(clk);
            start <= '0';
            
            wait until done = '1';
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            
            -- Store decrypted character
            str_len := str_len + 1;
            result_str(str_len) := character'val(to_integer(unsigned(output_char)));
            
            wait until rising_edge(clk);
            wait until rising_edge(clk);
        end loop;
        
        -- Write complete decrypted word
        write(line_out, result_str(1 to str_len));
        writeline(output_file, line_out);

        -- Skip blank line in input file
        readline(input_file, line_in);
        
        -- Mode 10 - Process second word
        file_close(temp_file);
        file_open(temp_file, "temp.txt", write_mode);
        
        mode <= "10";
        write(line_out, string'("Mode 10 - Case 2 Encrypt:"));
        writeline(output_file, line_out);
        
        -- Read and process second word
        readline(input_file, line_in);
        str_len := 0;
        
        -- Process each character
        for i in 1 to line_in'length loop
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
            
            -- Store encrypted character
            str_len := str_len + 1;
            result_str(str_len) := character'val(to_integer(unsigned(output_char)));
            
            wait until rising_edge(clk);
            wait until rising_edge(clk);
        end loop;
        
        -- Write complete encrypted word
        write(line_out, result_str(1 to str_len));
        writeline(output_file, line_out);
        write(line_out, result_str(1 to str_len));  -- Also write to temp file
        writeline(temp_file, line_out);

        -- Mode 11 - Decrypt second word
        mode <= "11";
        write(line_out, string'("Mode 11 - Case 2 Decrypt:"));
        writeline(output_file, line_out);
        
        -- Read encrypted word from temp file
        file_close(temp_file);
        file_open(temp_file, "temp.txt", read_mode);
        readline(temp_file, line_in);
        str_len := 0;
        
        -- Process each character
        for i in 1 to line_in'length loop
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
            
            -- Store decrypted character
            str_len := str_len + 1;
            result_str(str_len) := character'val(to_integer(unsigned(output_char)));
            
            wait until rising_edge(clk);
            wait until rising_edge(clk);
        end loop;
        
        -- Write complete decrypted word
        write(line_out, result_str(1 to str_len));
        writeline(output_file, line_out);

        -- Close files
        file_close(input_file);
        file_close(output_file);
        file_close(temp_file);
        
        wait;
    end process;
end behavior;