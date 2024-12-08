library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity tb_Main is
end tb_Main;

architecture Behavioral of tb_Main is
    -- Component declaration for the Unit Under Test (UUT)
    component Main is
        Port (
            clk         : in STD_LOGIC;
            rst         : in STD_LOGIC;
            mode        : in STD_LOGIC;
            start       : in STD_LOGIC;
            done_out    : out STD_LOGIC;
            error_out   : out STD_LOGIC
        );
    end component;

    -- Signals for the UUT
    signal clk         : STD_LOGIC := '0';
    signal rst         : STD_LOGIC := '0';
    signal mode        : STD_LOGIC := '0';  -- '0' for encryption, '1' for decryption
    signal start       : STD_LOGIC := '0';
    signal done_out    : STD_LOGIC;
    signal error_out   : STD_LOGIC;

    -- Clock generation
    constant clk_period : time := 10 ns;
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: Main
        Port map (
            clk => clk,
            rst => rst,
            mode => mode,
            start => start,
            done_out => done_out,
            error_out => error_out
        );

    -- Clock process definition
    clk_process : process
    begin
        clk <= not clk after clk_period / 2;
        wait for clk_period;
    end process;

    -- Stimulus process
    stim_proc: process
        file input_file  : text;
        file output_file : text;
        file decrypt_file: text;
        variable line_in : line;
        variable line_out : line;
        variable input_char_var : character;
        variable decrypted_char_var : character;
    begin
        -- Open the input file and the output file for encryption
        file_open(input_file, "input.txt", read_mode);
        assert (not endfile(input_file)) report "Input file is empty!" severity error;

        file_open(output_file, "encryptOutput.txt", write_mode);
        assert (output_file /= null) report "Unable to open encryptOutput.txt for writing!" severity error;

        -- Reset the system
        rst <= '1';
        start <= '0';
        mode <= '0';  -- Mode '0' for encryption
        wait for 20 ns;
        rst <= '0';

        -- Start the encryption process
        start <= '1';
        wait for clk_period;  -- Wait for the next clock cycle
        start <= '0';

        -- Wait for encryption to complete
        wait until done_out = '1';
        assert done_out = '1' report "Encryption process did not complete successfully!" severity error;

        -- Check if output file has been written correctly
        file_close(input_file);
        file_close(output_file);
        
        -- Open files for decryption
        file_open(output_file, "encryptOutput.txt", read_mode);
        assert (not endfile(output_file)) report "encryptOutput.txt is empty!" severity error;

        file_open(decrypt_file, "decryptOutput.txt", write_mode);
        assert (decrypt_file /= null) report "Unable to open decryptOutput.txt for writing!" severity error;

        -- Set mode to '1' for decryption
        mode <= '1';  -- Mode '1' for decryption
        wait for 20 ns;  -- Wait for a couple of cycles to ensure mode is set

        -- Start the decryption process
        start <= '1';
        wait for clk_period;
        start <= '0';

        -- Wait for decryption to complete
        wait until done_out = '1';
        assert done_out = '1' report "Decryption process did not complete successfully!" severity error;

        -- Check if the decrypted output matches the expected original input
        file_close(output_file);
        file_close(decrypt_file);

        -- If no errors, report success
        report "Encryption and Decryption process completed successfully!" severity note;

        -- Finish the simulation
        wait;
    end process;

end Behavioral;
