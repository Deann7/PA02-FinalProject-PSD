library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity MainTB is
end MainTB;

architecture Behavioral of MainTB is
    component Main
        Port (
            clk         : in STD_LOGIC;
            rst         : in STD_LOGIC;
            mode        : in STD_LOGIC;
            start       : in STD_LOGIC;
            done_out    : out STD_LOGIC;
            error_out   : out STD_LOGIC
        );
    end component;

    signal clk         : STD_LOGIC := '0';
    signal rst         : STD_LOGIC := '0';
    signal mode        : STD_LOGIC := '0';
    signal start       : STD_LOGIC := '0';
    signal done_out    : STD_LOGIC := '0';
    signal error_out   : STD_LOGIC := '0';

    constant CLK_PERIOD : time := 10 ns;

begin
    uut: Main PORT MAP (
        clk => clk,
        rst => rst,
        mode => mode,
        start => start,
        done_out => done_out,
        error_out => error_out
    );

    -- Clock generation
    clk_process: process
    begin
        while now < 2000 ns loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_process: process
        procedure write_input_file(data : string) is
            file input_file : text open write_mode is "input.txt";
            variable line_out : line;
        begin
            for i in data'range loop
                write(line_out, data(i));
                writeline(input_file, line_out);
            end loop;
            file_close(input_file);
            report "Input written to file: " & data severity note;
        end procedure;

        procedure read_output_file(is_encrypt : boolean; expected_data : string) is
            file output_file : text;
            variable line_in : line;
            variable output_char : character;
            variable output_string : string(1 to expected_data'length);
            variable index : integer := 1;
        begin
            if is_encrypt then
                report "Reading Encrypted Output" severity note;
                file_open(output_file, "encryptOutput.txt", read_mode);
            else
                report "Reading Decrypted Output" severity note;
                file_open(output_file, "decryptOutput.txt", read_mode);
            end if;

            index := 1;
            while not endfile(output_file) and index <= expected_data'length loop
                readline(output_file, line_in);
                read(line_in, output_char);
                output_string(index) := output_char;
                report "Output Char: " & output_char severity note;
                index := index + 1;
            end loop;

            file_close(output_file);

            if output_string /= expected_data then
                report "Got:      " & output_string severity note;
            else
                report "Output matches expected data" severity note;
            end if;
        end procedure;

    begin
        -- Scenario 1: Encryption
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';

        report "SKENARIO ENKRIPSI" severity note;
        write_input_file("hello");

        mode <= '0';
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        wait until done_out = '1';
        wait for CLK_PERIOD;

        read_output_file(true, "mlwwx");

        -- Scenario 2: Decryption
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';

        report "SKENARIO DEKRIPSI" severity note;
        mode <= '1';
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        wait until done_out = '1';
        wait for CLK_PERIOD;

        read_output_file(false, "hello");

        wait;
    end process;
end Behavioral;
