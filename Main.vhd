LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;

ENTITY Main IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        mode : IN STD_LOGIC; -- '0' for encrypt, '1' for decrypt
        start : IN STD_LOGIC;
        done_out : OUT STD_LOGIC;
        error_out : OUT STD_LOGIC
    );
END Main;

ARCHITECTURE Behavioral OF Main IS
    -- State definitions
    TYPE state_type IS (
        IDLE,
        OPEN_INPUT_FILE,
        READ_INPUT,
        CAESAR_PROCESS,
        HILL_PROCESS,
        WRITE_PHASE1,
        WRITE_FINAL_OUTPUT,
        COMPLETE,
        ERROR_STATE
    );

    SIGNAL current_state : state_type := IDLE;

    -- Component declarations
    COMPONENT caesarChiper
        PORT (
            input : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            mode : IN STD_LOGIC;
            shift_char : IN INTEGER RANGE 0 TO 25;
            cipher : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT hillCipher
        PORT (
            input : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            mode : IN STD_LOGIC;
            output : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    -- Signals
    SIGNAL input_char : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL caesar_out, hill_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL processing_mode : STD_LOGIC;
    SIGNAL done : STD_LOGIC := '0';
    SIGNAL error : STD_LOGIC := '0';
    CONSTANT CAESAR_SHIFT : INTEGER := 3;

BEGIN
    -- Component instantiations
    caesar_inst : caesarChiper PORT MAP(
        input => input_char,
        mode => processing_mode,
        shift_char => CAESAR_SHIFT,
        cipher => caesar_out
    );

    hill_inst : hillCipher PORT MAP(
        input => input_char,
        mode => processing_mode,
        output => hill_out
    );

    -- Output assignments
    done_out <= done;
    error_out <= error;

    -- Main state machine
    state_machine : PROCESS (clk, rst)
        FILE input_file : text;
        FILE phase1_file : text;
        FILE final_output_file : text;

        VARIABLE line_in : line;
        VARIABLE line_out : line;
        VARIABLE input_char_var : CHARACTER;
        VARIABLE is_file_open : BOOLEAN := false;
    BEGIN
        IF rst = '1' THEN
            current_state <= IDLE;
            done <= '0';
            error <= '0';
            processing_mode <= '0';
            is_file_open := false;
        ELSIF rising_edge(clk) THEN
            CASE current_state IS
                WHEN IDLE =>
                    IF start = '1' THEN
                        processing_mode <= mode;
                        current_state <= OPEN_INPUT_FILE;
                        done <= '0';
                        error <= '0';
                    END IF;

                WHEN OPEN_INPUT_FILE =>
                    IF processing_mode = '0' THEN
                        file_open(input_file, "input.txt", read_mode);
                        file_open(phase1_file, "phase1.txt", write_mode);
                        file_open(final_output_file, "encryptOutput.txt", write_mode);
                    ELSE
                        file_open(input_file, "encryptOutput.txt", read_mode); -- Gunakan file enkripsi sebagai input untuk dekripsi
                        file_open(final_output_file, "decryptOutput.txt", write_mode);
                    END IF;

                    is_file_open := true;
                    current_state <= READ_INPUT;

                WHEN READ_INPUT =>
                    IF NOT endfile(input_file) THEN
                        readline(input_file, line_in);
                        read(line_in, input_char_var);
                        input_char <= STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos(input_char_var), 8));

                        IF processing_mode = '0' THEN -- Gunakan processing_mode, bukan mode
                            current_state <= CAESAR_PROCESS;
                        ELSE
                            current_state <= HILL_PROCESS;
                        END IF;
                    ELSE
                        current_state <= COMPLETE;
                    END IF;

                WHEN HILL_PROCESS =>
                    IF processing_mode = '1' THEN -- Dekripsi
                        input_char <= hill_out; -- Dekripsi Hill Cipher dulu
                        write(line_out, CHARACTER'val(to_integer(unsigned(hill_out))));
                        -- writeline(phase1_file, line_out);  -- Ini yang menyebabkan error
                        current_state <= CAESAR_PROCESS;
                    ELSE -- Enkripsi
                        input_char <= hill_out;
                        write(line_out, CHARACTER'val(to_integer(unsigned(hill_out))));
                        writeline(phase1_file, line_out);
                        current_state <= WRITE_FINAL_OUTPUT;
                    END IF;

                WHEN CAESAR_PROCESS =>
                    IF processing_mode = '1' THEN -- Dekripsi
                        input_char <= caesar_out; -- Kemudian dekripsi Caesar Cipher
                        write(line_out, CHARACTER'val(to_integer(unsigned(caesar_out))));
                        writeline(final_output_file, line_out);
                        current_state <= WRITE_FINAL_OUTPUT;
                    ELSE -- Enkripsi (tetap sama)
                        input_char <= caesar_out;
                        write(line_out, CHARACTER'val(to_integer(unsigned(caesar_out))));
                        writeline(phase1_file, line_out);
                        current_state <= HILL_PROCESS;
                    END IF;

                WHEN WRITE_FINAL_OUTPUT =>
                    current_state <= READ_INPUT;

                WHEN COMPLETE =>
                    IF is_file_open THEN
                        file_close(input_file);
                        file_close(phase1_file);
                        file_close(final_output_file);
                        is_file_open := false;
                    END IF;

                    done <= '1';
                    current_state <= IDLE;

                WHEN ERROR_STATE =>
                    error <= '1';
                    current_state <= IDLE;

                WHEN OTHERS =>
                    current_state <= ERROR_STATE;
            END CASE;
        END IF;
    END PROCESS state_machine;
END Behavioral;