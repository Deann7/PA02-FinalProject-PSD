library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity Main_tb is
end Main_tb;

architecture Behavioral of Main_tb is
    -- Component Declaration for the Unit Under Test (UUT)
    component Main
        Port (
            clk     : in STD_LOGIC;
            rst     : in STD_LOGIC;
            mode    : in STD_LOGIC;  -- 0: Encrypt, 1: Decrypt
            start   : in STD_LOGIC;
            done    : out STD_LOGIC;
            error   : out STD_LOGIC
        );
    end component;

    -- Inputs
    signal clk     : STD_LOGIC := '0';
    signal rst     : STD_LOGIC := '0';
    signal mode    : STD_LOGIC := '0';
    signal start   : STD_LOGIC := '0';

    -- Outputs
    signal done    : STD_LOGIC;
    signal error   : STD_LOGIC;

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

    -- Procedure to create input file for testing
    procedure create_input_file(test_data : string) is
        file input_file : text open write_mode is "input.txt";
        variable line_buffer : line;
    begin
        write(line_buffer, test_data);
        writeline(input_file, line_buffer);
        file_close(input_file);
    end procedure;

    -- Procedure to read output file and check contents
    procedure check_output_file(expected_data : string) is
        file output_file : text open read_mode is "output.txt";
        variable line_buffer : line;
        variable read_data : string(1 to expected_data'length);
    begin
        if not endfile(output_file) then
            readline(output_file, line_buffer);
            read(line_buffer, read_data);
            assert read_data = expected_data
                report "Output mismatch. Expected: " & expected_data & ", Got: " & read_data
                severity failure;
        else
            assert false
                report "Output file is empty"
                severity failure;
        end if;
        file_close(output_file);
    end procedure;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: Main
    port map (
        clk     => clk,
        rst     => rst,
        mode    => mode,
        start   => start,
        done    => done,
        error   => error
    );

    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    stim_process: process
    begin
        -- Initialize
        rst <= '1';
        mode <= '0';  -- Encryption mode
        start <= '0';
        wait for CLK_PERIOD;
        rst <= '0';

        -- Test Encryption
        -- Create an input file
        create_input_file("HELLO");
        
        -- Start encryption
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        -- Wait for processing to complete
        wait until done = '1';

        -- Check output file for encryption
        check_output_file("ENCRYPTED");

        -- Test Decryption
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';

        mode <= '1';  -- Decryption mode
        create_input_file("ENCRYPTED");
        
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        -- Wait for processing to complete
        wait until done = '1';

        -- Check output file for decryption
        check_output_file("HELLO");

        -- End simulation
        report "Simulation completed successfully";
        wait;
    end process;
end Behavioral;