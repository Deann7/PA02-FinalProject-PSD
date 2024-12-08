library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity cipher_combined_tb is
end cipher_combined_tb;

architecture behavior of cipher_combined_tb is
    component cipher_combined
        port (
            clk         : in std_logic;
            reset       : in std_logic;
            mode        : in std_logic_vector(1 downto 0);
            start       : in std_logic;
            shift_value : in std_logic_vector(4 downto 0);
            input_char  : in std_logic_vector(7 downto 0);
            output_char : out std_logic_vector(7 downto 0);
            done        : out std_logic
        );
    end component;

    -- Test signals
    signal clk         : std_logic := '0';
    signal reset       : std_logic := '1';
    signal mode        : std_logic_vector(1 downto 0) := "00";
    signal start       : std_logic := '0';
    signal shift_value : std_logic_vector(4 downto 0) := "00011";
    signal input_char  : std_logic_vector(7 downto 0) := (others => '0');
    signal output_char : std_logic_vector(7 downto 0);
    signal done        : std_logic;
    signal stored_enc  : std_logic_vector(7 downto 0);
    
    constant clk_period : time := 10 ns;
    constant wait_time  : time := 50 ns;

begin
    -- UUT instantiation
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
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Store output process
    store_proc: process(clk)
    begin
        if rising_edge(clk) then
            if done = '1' then
                stored_enc <= output_char;
            end if;
        end if;
    end process;

    -- Stimulus process
    stim_proc: process
        procedure process_char(
            input_val : in std_logic_vector(7 downto 0);
            mode_val : in std_logic_vector(1 downto 0)) is
        begin
            mode <= mode_val;
            start <= '1';
            input_char <= input_val;
            wait for clk_period;
            start <= '0';
            wait until done = '1';
            wait for clk_period;
            wait for wait_time;
        end procedure;
    begin
        -- Initial reset
        reset <= '1';
        wait for clk_period * 2;
        reset <= '0';
        wait for clk_period * 2;

        -- Test uppercase letters
        -- Encrypt 'A'
        process_char(x"41", "00");  -- Caesar -> Hill encryption
        process_char(stored_enc, "01");  -- Hill -> Caesar decryption

        -- Test lowercase letters
        -- Encrypt 'a'
        process_char(x"61", "00");  -- Caesar -> Hill encryption
        process_char(stored_enc, "01");  -- Hill -> Caesar decryption

        -- Test Case 2 encryption/decryption
        -- Encrypt 'B'
        process_char(x"42", "10");  -- Hill -> Caesar encryption
        process_char(stored_enc, "11");  -- Caesar -> Hill decryption

        -- Test special characters
        -- Space character
        process_char(x"20", "00");  -- Caesar -> Hill encryption
        process_char(stored_enc, "01");  -- Hill -> Caesar decryption

        wait;
    end process;

    -- Monitor process
    monitor_proc: process(clk)
        variable msg : line;
    begin
        if rising_edge(clk) then
            if done = '1' then
                write(msg, string'("Mode: "));
                hwrite(msg, mode);
                write(msg, string'(" Input: "));
                hwrite(msg, input_char);
                write(msg, string'(" Output: "));
                hwrite(msg, output_char);
                write(msg, string'(" Stored: "));
                hwrite(msg, stored_enc);
                writeline(output, msg);
            end if;
        end if;
    end process;

end behavior;