library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity Main is
    Port (
        clk         : in STD_LOGIC;
        rst         : in STD_LOGIC;
        mode        : in STD_LOGIC;  -- '0' for encrypt, '1' for decrypt
        start       : in STD_LOGIC;
        done_out    : out STD_LOGIC;
        error_out   : out STD_LOGIC
    );
end Main;

architecture Behavioral of Main is
    -- State definitions
    type state_type is (
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
    
    signal current_state : state_type := IDLE;
    
    -- Component declarations
    component caesarChiper 
        port (
            input       : in  std_logic_vector(7 downto 0);
            mode        : in  std_logic;
            shift_char  : in  integer range 0 to 25;
            cipher      : out std_logic_vector(7 downto 0)
        );
    end component;

    component hillCipher 
        port (
            input  : in STD_LOGIC_VECTOR(7 downto 0);
            mode   : in STD_LOGIC;
            output : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- Signals
    signal input_char : std_logic_vector(7 downto 0);
    signal caesar_out, hill_out : std_logic_vector(7 downto 0);
    signal processing_mode : std_logic;
    signal done : std_logic := '0';
    signal error : std_logic := '0';
    constant CAESAR_SHIFT : integer := 3;

begin
    -- Component instantiations
    caesar_inst : caesarChiper port map (
        input => input_char,
        mode => processing_mode,
        shift_char => CAESAR_SHIFT,
        cipher => caesar_out
    );

    hill_inst : hillCipher port map (
        input => input_char,
        mode => processing_mode,
        output => hill_out
    );

    -- Output assignments
    done_out <= done;
    error_out <= error;

    -- Main state machine
    state_machine: process(clk, rst)
        file input_file  : text;
        file phase1_file : text;
        file final_output_file : text;
        
        variable line_in : line;
        variable line_out : line;
        variable input_char_var : character;
        variable is_file_open : boolean := false;
    begin
        if rst = '1' then
            current_state <= IDLE;
            done <= '0';
            error <= '0';
            processing_mode <= '0';
            is_file_open := false;
        elsif rising_edge(clk) then
            case current_state is
                when IDLE =>
                    if start = '1' then
                        processing_mode <= mode;
                        current_state <= OPEN_INPUT_FILE;
                        done <= '0';
                        error <= '0';
                    end if;

                when OPEN_INPUT_FILE =>
                    file_open(input_file, "input.txt", read_mode);
                    
                    if processing_mode = '0' then
                        file_open(phase1_file, "phase1.txt", write_mode);
                        file_open(final_output_file, "encryptOutput.txt", write_mode);
                    else
                        file_open(phase1_file, "phase1.txt", write_mode);
                        file_open(final_output_file, "decryptOutput.txt", write_mode);
                    end if;
                    
                    is_file_open := true;
                    current_state <= READ_INPUT;

                when READ_INPUT =>
                    if not endfile(input_file) then
                        readline(input_file, line_in);
                        read(line_in, input_char_var);
                        input_char <= std_logic_vector(to_unsigned(character'pos(input_char_var), 8));
                        
                        current_state <= CAESAR_PROCESS;
                    else
                        current_state <= COMPLETE;
                    end if;

                    when HILL_PROCESS =>
                    if processing_mode = '1' then  -- Dekripsi
                        input_char <= hill_out;    -- Dekripsi Hill Cipher dulu
                        write(line_out, character'val(to_integer(unsigned(hill_out))));
                        writeline(phase1_file, line_out);
                        current_state <= CAESAR_PROCESS;
                    else  -- Enkripsi (tetap sama)
                        input_char <= hill_out;
                        write(line_out, character'val(to_integer(unsigned(hill_out))));
                        writeline(final_output_file, line_out);
                        current_state <= WRITE_FINAL_OUTPUT;
                    end if;
                
                when CAESAR_PROCESS =>
                    if processing_mode = '1' then  -- Dekripsi
                        input_char <= caesar_out;  -- Kemudian dekripsi Caesar Cipher
                        write(line_out, character'val(to_integer(unsigned(caesar_out))));
                        writeline(final_output_file, line_out);
                        current_state <= WRITE_FINAL_OUTPUT;
                    else  -- Enkripsi (tetap sama)
                        input_char <= caesar_out;
                        write(line_out, character'val(to_integer(unsigned(caesar_out))));
                        writeline(phase1_file, line_out);
                        current_state <= HILL_PROCESS;
                    end if;

                when WRITE_FINAL_OUTPUT =>
                    current_state <= READ_INPUT;

                when COMPLETE =>
                    if is_file_open then
                        file_close(input_file);
                        file_close(phase1_file);
                        file_close(final_output_file);
                        is_file_open := false;
                    end if;
                    
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