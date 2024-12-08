library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity caesar_cipher_tb is
end caesar_cipher_tb;

architecture Behavioral of caesar_cipher_tb is
    -- Komponen yang akan diuji
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
    
    -- Sinyal untuk simulasi
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal mode : STD_LOGIC := '0';
    signal shift_value : STD_LOGIC_VECTOR(4 downto 0) := "00011";  -- Shift 3
    signal input_char : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal processed_char : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Konstanta untuk periode clock
    constant CLK_PERIOD : time := 10 ns;
begin
    -- Instantiasi Unit Under Test (UUT)
    uut: caesar_cipher PORT MAP (
        clk => clk,
        reset => reset,
        mode => mode,
        shift_value => shift_value,
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
        
        -- Skenario 1: Enkripsi 'A' dengan shift 3
        mode <= '0';  -- Mode enkripsi
        input_char <= x"41";  -- 'A'
        wait for CLK_PERIOD;
        
        -- Skenario 2: Enkripsi 'Z' dengan shift 3
        input_char <= x"5A";  -- 'Z'
        wait for CLK_PERIOD;
        
        -- Skenario 3: Dekripsi 'D' dengan shift 3
        mode <= '1';  -- Mode dekripsi
        input_char <= x"44";  -- 'D'
        wait for CLK_PERIOD;
        
        -- Skenario 4: Karakter non-alfabetik
        input_char <= x"21";  -- '!'
        wait for CLK_PERIOD;
        
        -- Skenario 5: Enkripsi huruf kecil
        mode <= '0';  -- Mode enkripsi
        input_char <= x"61";  -- 'a'
        wait for CLK_PERIOD;
        
        wait;
    end process;
end Behavioral;