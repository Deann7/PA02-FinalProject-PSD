library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity caesar_cipher is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        mode : in STD_LOGIC;  -- '0' untuk enkripsi, '1' untuk dekripsi
        shift_value : in STD_LOGIC_VECTOR(4 downto 0);  -- Nilai pergeseran (0-25)
        input_char : in STD_LOGIC_VECTOR(7 downto 0);  -- Input karakter 8-bit
        processed_char : out STD_LOGIC_VECTOR(7 downto 0)  -- Output karakter terproses
    );
end caesar_cipher;

architecture Behavioral of caesar_cipher is
begin
    process(clk, reset)
        variable char_value : integer range 0 to 25;
        variable shifted_value : integer range 0 to 25;
        variable shift : integer range 0 to 25;
    begin
        -- Konversi shift_value ke integer
        shift := to_integer(unsigned(shift_value)) mod 26;
        
        if reset = '1' then
            processed_char <= (others => '0');
        elsif rising_edge(clk) then
            -- Proses untuk huruf besar (A-Z)
            if input_char >= x"41" and input_char <= x"5A" then
                -- Konversi ke nilai numerik (A=0, B=1, dst)
                char_value := to_integer(unsigned(input_char)) - 65;
                
                -- Enkripsi atau dekripsi berdasarkan mode
                if mode = '0' then  -- Enkripsi
                    shifted_value := (char_value + shift) mod 26;
                else  -- Dekripsi
                    shifted_value := (char_value - shift + 26) mod 26;
                end if;
                
                -- Konversi kembali ke karakter ASCII huruf besar
                processed_char <= STD_LOGIC_VECTOR(to_unsigned(shifted_value + 65, 8));
            
            -- Proses untuk huruf kecil (a-z)
            elsif input_char >= x"61" and input_char <= x"7A" then
                -- Konversi ke nilai numerik (a=0, b=1, dst)
                char_value := to_integer(unsigned(input_char)) - 97;
                
                -- Enkripsi atau dekripsi berdasarkan mode
                if mode = '0' then  -- Enkripsi
                    shifted_value := (char_value + shift) mod 26;
                else  -- Dekripsi
                    shifted_value := (char_value - shift + 26) mod 26;
                end if;
                
                -- Konversi kembali ke karakter ASCII huruf kecil
                processed_char <= STD_LOGIC_VECTOR(to_unsigned(shifted_value + 97, 8));
            
            -- Jika bukan huruf, kembalikan karakter asli
            else
                processed_char <= input_char;
            end if;
        end if;
    end process;
end Behavioral;