library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cipher_combined is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        mode : in STD_LOGIC_VECTOR(1 downto 0);  -- "00": Case1-Encrypt, "01": Case1-Decrypt, "10": Case2-Encrypt, "11": Case2-Decrypt
        start : in STD_LOGIC;
        shift_value : in STD_LOGIC_VECTOR(4 downto 0);
        input_char : in STD_LOGIC_VECTOR(7 downto 0);
        output_char : out STD_LOGIC_VECTOR(7 downto 0);
        done : out STD_LOGIC
    );
end cipher_combined;

architecture Behavioral of cipher_combined is
    type state_type is (IDLE, 
                       CAESAR_ENC1, HILL_ENC1,   -- Case 1 Encrypt
                       HILL_DEC1, CAESAR_DEC1,   -- Case 1 Decrypt
                       HILL_ENC2, CAESAR_ENC2,   -- Case 2 Encrypt
                       CAESAR_DEC2, HILL_DEC2);  -- Case 2 Decrypt
    signal current_state, next_state : state_type;
    
    signal caesar_mode, hill_mode : STD_LOGIC;
    signal caesar_input, hill_input : STD_LOGIC_VECTOR(7 downto 0);
    signal caesar_enc_out, hill_enc_out : STD_LOGIC_VECTOR(7 downto 0);
    signal intermediate_data : STD_LOGIC_VECTOR(7 downto 0);
    signal state_delay : integer range 0 to 3;

    component caesar_cipher
        Port ( 
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            mode : in STD_LOGIC;
            shift_value : in STD_LOGIC_VECTOR(4 downto 0);
            input_char : in STD_LOGIC_VECTOR(7 downto 0);
            processed_char : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    component hill_cipher_combined
        Port ( 
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            mode : in STD_LOGIC;
            input_char : in STD_LOGIC_VECTOR(7 downto 0);
            processed_char : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

begin
    caesar_inst: caesar_cipher port map (
        clk => clk,
        reset => reset,
        mode => caesar_mode,
        shift_value => shift_value,
        input_char => caesar_input,
        processed_char => caesar_enc_out
    );
    
    hill_inst: hill_cipher_combined port map (
        clk => clk,
        reset => reset,
        mode => hill_mode,
        input_char => hill_input,
        processed_char => hill_enc_out
    );

    -- State and Delay Control
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
            state_delay <= 0;
            intermediate_data <= (others => '0');
        elsif rising_edge(clk) then
            case current_state is
                when IDLE =>
                    if start = '1' then
                        case mode is
                            when "00" => next_state <= CAESAR_ENC1;  -- Case 1 Encrypt
                            when "01" => next_state <= HILL_DEC1;    -- Case 1 Decrypt
                            when "10" => next_state <= HILL_ENC2;    -- Case 2 Encrypt
                            when "11" => next_state <= CAESAR_DEC2;  -- Case 2 Decrypt
                            when others => next_state <= IDLE;
                        end case;
                        state_delay <= 0;
                    end if;

                -- Case 1 Encrypt States
                when CAESAR_ENC1 =>
                    if state_delay = 2 then
                        intermediate_data <= caesar_enc_out;
                        next_state <= HILL_ENC1;
                        state_delay <= 0;
                    else
                        state_delay <= state_delay + 1;
                    end if;

                when HILL_ENC1 =>
                    if state_delay = 2 then
                        next_state <= IDLE;
                        state_delay <= 0;
                    else
                        state_delay <= state_delay + 1;
                    end if;

                -- Case 1 Decrypt States
                when HILL_DEC1 =>
                    if state_delay = 2 then
                        intermediate_data <= hill_enc_out;
                        next_state <= CAESAR_DEC1;
                        state_delay <= 0;
                    else
                        state_delay <= state_delay + 1;
                    end if;

                when CAESAR_DEC1 =>
                    if state_delay = 2 then
                        next_state <= IDLE;
                        state_delay <= 0;
                    else
                        state_delay <= state_delay + 1;
                    end if;

                -- Case 2 Encrypt States
                when HILL_ENC2 =>
                    if state_delay = 2 then
                        intermediate_data <= hill_enc_out;
                        next_state <= CAESAR_ENC2;
                        state_delay <= 0;
                    else
                        state_delay <= state_delay + 1;
                    end if;

                when CAESAR_ENC2 =>
                    if state_delay = 2 then
                        next_state <= IDLE;
                        state_delay <= 0;
                    else
                        state_delay <= state_delay + 1;
                    end if;

                -- Case 2 Decrypt States
                when CAESAR_DEC2 =>
                    if state_delay = 2 then
                        intermediate_data <= caesar_enc_out;
                        next_state <= HILL_DEC2;
                        state_delay <= 0;
                    else
                        state_delay <= state_delay + 1;
                    end if;

                when HILL_DEC2 =>
                    if state_delay = 2 then
                        next_state <= IDLE;
                        state_delay <= 0;
                    else
                        state_delay <= state_delay + 1;
                    end if;
            end case;
            current_state <= next_state;
        end if;
    end process;

    -- Input Routing
    process(current_state, input_char, intermediate_data)
    begin
        case current_state is
            when CAESAR_ENC1 =>
                caesar_input <= input_char;
            when HILL_ENC1 =>
                hill_input <= intermediate_data;
            when HILL_DEC1 =>
                hill_input <= input_char;
            when CAESAR_DEC1 =>
                caesar_input <= intermediate_data;
            when HILL_ENC2 =>
                hill_input <= input_char;
            when CAESAR_ENC2 =>
                caesar_input <= intermediate_data;
            when CAESAR_DEC2 =>
                caesar_input <= input_char;
            when HILL_DEC2 =>
                hill_input <= intermediate_data;
            when others =>
                caesar_input <= (others => '0');
                hill_input <= (others => '0');
        end case;
    end process;

    -- Mode Control
    process(current_state)
    begin
        case current_state is
            when CAESAR_ENC1 | CAESAR_ENC2 =>
                caesar_mode <= '0';  -- Encrypt
                hill_mode <= '0';
            when HILL_ENC1 | HILL_ENC2 =>
                caesar_mode <= '0';
                hill_mode <= '0';    -- Encrypt
            when HILL_DEC1 | HILL_DEC2 =>
                caesar_mode <= '0';
                hill_mode <= '1';    -- Decrypt
            when CAESAR_DEC1 | CAESAR_DEC2 =>
                caesar_mode <= '1';  -- Decrypt
                hill_mode <= '0';
            when others =>
                caesar_mode <= '0';
                hill_mode <= '0';
        end case;
    end process;

    -- Output Control
    process(current_state, caesar_enc_out, hill_enc_out)
    begin
        case current_state is
            when CAESAR_ENC1 | CAESAR_ENC2 =>
                output_char <= caesar_enc_out;
                done <= '0';
            when HILL_ENC1 | HILL_ENC2 =>
                output_char <= hill_enc_out;
                done <= '1';  -- Done for encryption
            when HILL_DEC1 | HILL_DEC2 =>
                output_char <= hill_enc_out;
                done <= '0';
            when CAESAR_DEC1 | CAESAR_DEC2 =>
                output_char <= caesar_enc_out;
                done <= '1';  -- Done for decryption
            when others =>
                output_char <= (others => '0');
                done <= '0';
        end case;
    end process;

end Behavioral;