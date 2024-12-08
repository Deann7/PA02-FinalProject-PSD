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
        OPEN_INPUT_FILE,
        READ_INPUT, 
        CAESAR_PROCESS,
        HILL_PROCESS, 
        WRITE_OUTPUT, 
        COMPLETE, 
        ERROR_STATE
    );
    
    component caesarCipher is
        port (
            input   : in  std_logic_vector(7 downto 0);
            cipher  : out std_logic_vector(7 downto 0)
        );
    end component;

    component hillCipher is
        port (
            input  : in STD_LOGIC_VECTOR(7 downto 0);
            mode   : in STD_LOGIC_VECTOR(1 downto 0);
            output : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    signal input_char : std_logic_vector(7 downto 0);
    signal caesar_out, hill_out : std_logic_vector(7 downto 0);
    signal current_state : state_type := IDLE;
    signal main_mode : std_logic;
    signal hill_mode : std_logic_vector(1 downto 0);
    signal done : std_logic := '0';
    signal error : std_logic := '0';

begin
    -- Hill cipher instantiation
    hill_inst : hillCipher port map (
        input => input_char,
        mode => hill_mode,
        output => hill_out
    );

    -- Caesar cipher instantiation
    caesar_inst : caesarCipher port map (
        input => input_char,
        cipher => caesar_out
    );

    done_out <= done;
    error_out <= error;

    -- State Machine Process
    state_machine: process(clk, rst)
        file input_file  : text;
        file output_file : text;
        variable line_in : line;
        variable line_out : line;
        variable input_char_var : character;
    begin
        if rst = '1' then
            current_state <= IDLE;
            done <= '0';
            error <= '0';
        elsif rising_edge(clk) then
            case current_state is
                when IDLE =>
                    if start = '1' then
                        main_mode <= mode;
                        current_state <= OPEN_INPUT_FILE;
                        done <= '0';
                        error <= '0';
                    end if;

                when OPEN_INPUT_FILE =>
                    if main_mode = '0' then
                        file_open(input_file, "input.txt", read_mode);
                        file_open(output_file, "encryptOutput.txt", write_mode);
                        hill_mode <= "00";  -- Enkripsi normal
                    else
                        file_open(input_file, "encryptOutput.txt", read_mode);
                        file_open(output_file, "decryptOutput.txt", write_mode);
                        hill_mode <= "01";  -- Dekripsi (invers matriks)
                    end if;
                    current_state <= READ_INPUT;

                when READ_INPUT =>
                    if not endfile(input_file) then
                        readline(input_file, line_in);
                        read(line_in, input_char_var);
                        input_char <= std_logic_vector(to_unsigned(character'pos(input_char_var), 8));
                        
                        if main_mode = '0' then
                            current_state <= CAESAR_PROCESS; -- Mode enkripsi: mulai dari Caesar
                        else
                            current_state <= HILL_PROCESS;  -- Mode dekripsi: mulai dari Hill Cipher
                        end if;
                    else
                        file_close(input_file);
                        file_close(output_file);
                        current_state <= COMPLETE;
                    end if;

                when CAESAR_PROCESS =>
                    -- Proses Caesar Cipher di mode enkripsi
                    input_char <= caesar_out;
                    current_state <= HILL_PROCESS; 

                when HILL_PROCESS =>
                    -- Proses Hill Cipher di mode enkripsi
                    input_char <= hill_out;
                    current_state <= WRITE_OUTPUT;

                when WRITE_OUTPUT =>
                    write(line_out, character'val(to_integer(unsigned(input_char))));  -- Menulis ke file
                    writeline(output_file, line_out);
                    current_state <= READ_INPUT;

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
