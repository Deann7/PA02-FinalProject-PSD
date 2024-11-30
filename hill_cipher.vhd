library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hill_cipher is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        input_char : in STD_LOGIC_VECTOR(7 downto 0); -- Input karakter 8-bit
        encrypted_char : out STD_LOGIC_VECTOR(7 downto 0) -- Output karakter terenkripsi
    );
end hill_cipher;

architecture Behavioral of hill_cipher is
    -- Matriks kunci 2x2 untuk Hill Cipher
    constant KEY_MATRIX : STD_LOGIC_VECTOR(15 downto 0) := x"0305"; 
    -- [0  3]
    -- [0  5]

    -- Fungsi untuk menghitung enkripsi single karakter
    function encrypt_char(char_val : integer; key_mat : STD_LOGIC_VECTOR(15 downto 0)) return integer is
        variable result : integer;
        variable k11, k12, k21, k22 : integer;
    begin
        -- Ekstrak elemen matriks kunci
        k11 := to_integer(unsigned(key_mat(15 downto 12)));
        k12 := to_integer(unsigned(key_mat(11 downto 8)));
        k21 := to_integer(unsigned(key_mat(7 downto 4)));
        k22 := to_integer(unsigned(key_mat(3 downto 0)));

        -- Perhitungan enkripsi: (k11*x + k12*y) mod 26
        result := (k11 * char_val + k12 * char_val) mod 26;
        
        return result;
    end function;

begin
    process(clk, reset)
        variable char_value : integer range 0 to 25;
        variable encrypted_value : integer range 0 to 25;
    begin
        if reset = '1' then
            encrypted_char <= (others => '0');
        elsif rising_edge(clk) then
            -- Konversi input karakter ke nilai numerik (A=0, B=1, dst)
            if input_char >= x"41" and input_char <= x"5A" then
                char_value := to_integer(unsigned(input_char)) - 65;
                
                -- Enkripsi karakter
                encrypted_value := encrypt_char(char_value, KEY_MATRIX);
                
                -- Konversi kembali ke karakter ASCII
                encrypted_char <= STD_LOGIC_VECTOR(to_unsigned(encrypted_value + 65, 8));
            elsif input_char >= x"61" and input_char <= x"7A" then
                char_value := to_integer(unsigned(input_char)) - 97;
                
                -- Enkripsi karakter
                encrypted_value := encrypt_char(char_value, KEY_MATRIX);
                
                -- Konversi kembali ke karakter ASCII
                encrypted_char <= STD_LOGIC_VECTOR(to_unsigned(encrypted_value + 97, 8));
            else
                encrypted_char <= input_char;
            end if;
        end if;
    end process;
end Behavioral;