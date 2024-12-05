library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity Main is
    Port (
        clk         : in STD_LOGIC;
        rst         : in STD_LOGIC;
        mode        : in STD_LOGIC;
        start       : in STD_LOGIC;
        done_out    : out STD_LOGIC;
        error_out   : out STD_LOGIC
    );
end Main;

architecture Behavioral of Main is
    type state_type is (
        IDLE, 
        READ_INPUT, 
        CAESAR_PROCESS, 
        HILL_PROCESS, 
        WRITE_OUTPUT, 
        COMPLETE, 
        ERROR_STATE
    );
    
    signal current_state : state_type := IDLE;
    signal next_state : state_type := IDLE;

    component caesarCipher is
        port (
            input   : in  std_logic_vector(7 downto 0);
            cipher  : out std_logic_vector(7 downto 0)
        );
    end component;

    component hillCipher is
        port (
            input  : in STD_LOGIC_VECTOR(7 downto 0);
            mode   : in STD_LOGIC;
            output : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    signal input_char : std_logic_vector(7 downto 0);
    signal caesar_out, hill_out : std_logic_vector(7 downto 0);
    signal processing_mode : std_logic;
    signal done : std_logic := '0';
    signal error : std_logic := '0';

begin
    caesar_inst : caesarCipher port map (
        input => input_char,
        cipher => caesar_out
    );

    hill_inst : hillCipher port map (
        input => input_char,
        mode => processing_mode,
        output => hill_out
    );

    done_out <= done;
    error_out <= error;

    state_machine: process(clk, rst)
        file input_file  : text open read_mode is "input.txt";
        file output_file : text open write_mode is "phase1.txt";
        file encrypt_file : text open write_mode is "encryptOutput.txt";
        file decrypt_file : text open write_mode is "decryptOutput.txt";

        variable line_in : line;
        variable line_out : line;
        variable input_char_var : character;
    begin
        if rst = '1' then
            current_state <= IDLE;
            done <= '0';
            error <= '0';
            processing_mode <= '0';
        elsif rising_edge(clk) then
            case current_state is
                when IDLE =>
                    if start = '1' then
                        processing_mode <= mode;
                        current_state <= READ_INPUT;
                        done <= '0';
                        error <= '0';
                    end if;

                when READ_INPUT =>
                    if not endfile(input_file) then
                        readline(input_file, line_in);
                        read(line_in, input_char_var);
                        input_char <= std_logic_vector(to_unsigned(character'pos(input_char_var), 8));
                        current_state <= CAESAR_PROCESS;
                    else
                        current_state <= COMPLETE;
                    end if;

                when CAESAR_PROCESS =>
                    write(line_out, string'("Mode: "));
                    if mode = '0' then
                        write(line_out, string'("Encrypt"));
                    else
                        write(line_out, string'("Decrypt"));
                    end if;
                    writeline(output_file, line_out);
                    
                    current_state <= HILL_PROCESS;

                when HILL_PROCESS =>
                    if mode = '0' then
                        input_char <= caesar_out;
                    else
                        input_char <= caesar_out;
                    end if;

                    write(line_out, string'("Ciphered text: "));
                    write(line_out, character'val(to_integer(unsigned(caesar_out))));
                    writeline(output_file, line_out);
                    
                    if mode = '0' then
                        writeline(encrypt_file, line_out);
                    else
                        writeline(decrypt_file, line_out);
                    end if;

                    current_state <= WRITE_OUTPUT;

                when WRITE_OUTPUT =>
                    current_state <= COMPLETE;

                when COMPLETE =>
                    done <= '1';
                    current_state <= IDLE;

                when ERROR_STATE =>
                    error <= '1';
                    current_state <= IDLE;

                when others =>
                    current_state <= ERROR_STATE;
            end case;
        end if;
    end process state_machine;
end Behavioral;