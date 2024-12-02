library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity Main is
    Port (
        clk         : in STD_LOGIC;
        rst         : in STD_LOGIC;
        mode        : in STD_LOGIC;  -- 0: Encrypt, 1: Decrypt
        start       : in STD_LOGIC;
        done        : out STD_LOGIC;
        error       : out STD_LOGIC
    );
end Main;

architecture Structural of Main is
    type state_type is (
        IDLE, 
        INIT, 
        READ_INPUT, 
        PROCESS_CHAR, 
        WRITE_OUTPUT, 
        COMPLETE, 
        ERROR_STATE
    );
    
    component caesarChiper is
        port (
            input       : in  std_logic_vector(7 downto 0);
            shift_char  : in  integer range 0 to 25;
            cipher      : out std_logic_vector(7 downto 0)
        );
    end component;

    component hillCipher is
        port (
            input  : in STD_LOGIC_VECTOR(7 downto 0);
            mode   : in STD_LOGIC;
            output : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    signal current_state, next_state : state_type;
    signal input_text, processed_text : std_logic_vector(7 downto 0);
    signal caesar_out, hill_out : std_logic_vector(7 downto 0);
    
    signal shift_value  : integer range 0 to 25 := 3;
    signal processing_mode : std_logic;

    -- Explicit file handling signals
    signal file_read_done : boolean := false;
    signal file_write_done : boolean := false;

begin
    caesar_inst : caesarChiper port map (
        input => input_text,
        shift_char => shift_value,
        cipher => caesar_out
    );

    hill_inst : hillCipher port map (
        input => input_text,
        mode => processing_mode,
        output => hill_out
    );

    file_process: process(clk, rst)
        file input_file  : text open read_mode is "input.txt";
        file output_file : text open write_mode is "output.txt";
        variable input_line  : line;
        variable output_line : line;
        variable char_var    : character;
        variable temp_processed : std_logic_vector(7 downto 0);
    begin
        if rst = '1' then
            file_read_done <= false;
            file_write_done <= false;
        elsif rising_edge(clk) then
            if not file_read_done then
                if not endfile(input_file) then
                    readline(input_file, input_line);
                    read(input_line, char_var);
                    input_text <= std_logic_vector(to_unsigned(character'pos(char_var), 8));

                    -- Process based on mode
                    if processing_mode = '0' then  -- Encryption
                        input_text <= caesar_out;
                        temp_processed := hill_out;
                    else  -- Decryption
                        input_text <= hill_out;
                        temp_processed := caesar_out;
                    end if;

                    -- Write processed character
                    write(output_line, character'val(to_integer(unsigned(temp_processed))));
                    writeline(output_file, output_line);
                else
                    file_read_done <= true;
                    file_write_done <= true;
                end if;
            end if;
        end if;
    end process;

    state_machine: process(clk, rst)
    begin
        if rst = '1' then
            current_state <= IDLE;
            processing_mode <= '0';
            done <= '0';
            error <= '0';
        elsif rising_edge(clk) then
            if start = '1' then
                processing_mode <= mode;
                if file_write_done then
                    done <= '1';
                end if;
            end if;
        end if;
    end process;
end Structural;