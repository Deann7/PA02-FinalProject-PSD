library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cipher_combined is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        mode : in STD_LOGIC;  -- '0' for case 1, '1' for case 2
        start : in STD_LOGIC;
        shift_value : in STD_LOGIC_VECTOR(4 downto 0);
        input_char : in STD_LOGIC_VECTOR(7 downto 0);
        output_char : out STD_LOGIC_VECTOR(7 downto 0);
        done : out STD_LOGIC
    );
end cipher_combined;

architecture Behavioral of cipher_combined is
    -- FSM States
    type state_type is (IDLE, 
                       CAESAR_ENC, HILL_ENC, HILL_DEC, CAESAR_DEC,  -- Case 1
                       HILL_ENC2, CAESAR_ENC2, CAESAR_DEC2, HILL_DEC2); -- Case 2
    signal current_state, next_state : state_type;
    
    -- Internal signals for intermediate results
    signal caesar_enc_out, hill_enc_out, hill_dec_out, caesar_dec_out : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Component declarations
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
    -- Component instantiations
    caesar_inst: caesar_cipher port map (
        clk => clk,
        reset => reset,
        mode => mode,
        shift_value => shift_value,
        input_char => input_char,
        processed_char => caesar_enc_out
    );
    
    hill_inst: hill_cipher_combined port map (
        clk => clk,
        reset => reset,
        mode => mode,
        input_char => caesar_enc_out,
        processed_char => hill_enc_out
    );
    
    -- FSM Process
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
    
    -- Next State Logic
    process(current_state, start, mode)
    begin
        case current_state is
            when IDLE =>
                if start = '1' then
                    if mode = '0' then
                        next_state <= CAESAR_ENC;
                    else
                        next_state <= HILL_ENC2;
                    end if;
                else
                    next_state <= IDLE;
                end if;
                
            -- Case 1 states
            when CAESAR_ENC =>
                next_state <= HILL_ENC;
            when HILL_ENC =>
                next_state <= HILL_DEC;
            when HILL_DEC =>
                next_state <= CAESAR_DEC;
            when CAESAR_DEC =>
                next_state <= IDLE;
                
            -- Case 2 states
            when HILL_ENC2 =>
                next_state <= CAESAR_ENC2;
            when CAESAR_ENC2 =>
                next_state <= CAESAR_DEC2;
            when CAESAR_DEC2 =>
                next_state <= HILL_DEC2;
            when HILL_DEC2 =>
                next_state <= IDLE;
        end case;
    end process;
    
    -- Output Logic
    process(current_state, caesar_enc_out, hill_enc_out, hill_dec_out, caesar_dec_out)
    begin
        case current_state is
            when IDLE =>
                output_char <= (others => '0');
                done <= '0';
                
            when CAESAR_ENC =>
                output_char <= caesar_enc_out;
                done <= '0';
                
            when HILL_ENC | HILL_ENC2 =>
                output_char <= hill_enc_out;
                done <= '0';
                
            when HILL_DEC | HILL_DEC2 =>
                output_char <= hill_dec_out;
                done <= '0';
                
            when CAESAR_DEC | CAESAR_DEC2 =>
                output_char <= caesar_dec_out;
                done <= '1';
                
            when others =>
                output_char <= (others => '0');
                done <= '0';
        end case;
    end process;

end Behavioral;