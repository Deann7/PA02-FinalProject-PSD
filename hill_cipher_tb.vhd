library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hill_cipher_tb is
end hill_cipher_tb;

architecture Behavioral of hill_cipher_tb is
    -- Komponen yang akan diuji
    component hill_cipher_combined
        Port ( 
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            mode : in STD_LOGIC;
            input_char : in STD_LOGIC_VECTOR(7 downto 0);
            processed_char : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    -- Sinyal untuk simulasi
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal mode : STD_LOGIC := '0';
    signal input_char : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal processed_char : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Konstanta untuk periode clock
    constant CLK_PERIOD : time := 10 ns;
begin
    -- Instantiasi Unit Under Test (UUT)
    uut: hill_cipher_combined PORT MAP (
        clk => clk,
        reset => reset,
        mode => mode,
        input_char => input_char,
        processed_char => processed_char
    );
    
    -- Proses pembangkit clock
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Proses stimulasi
    stim_proc: process
    begin
        -- Reset awal
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        
        -- Skenario 1: Enkripsi 'A'
        mode <= '0';  -- Mode enkripsi
        input_char <= x"41";  -- 'A'
        wait for CLK_PERIOD;
        
        -- Skenario 2: Enkripsi 'B'
        input_char <= x"42";  -- 'B'
        wait for CLK_PERIOD;
        
        -- Skenario 3: Dekripsi 'D'
        mode <= '1';  -- Mode dekripsi
        input_char <= x"44";  -- 'D'
        wait for CLK_PERIOD;
        
        -- Skenario 4: Karakter non-alfabetik
        input_char <= x"21";  -- '!'
        wait for CLK_PERIOD;
        
        wait;
    end process;
end Behavioral;