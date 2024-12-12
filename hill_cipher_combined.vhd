library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hill_cipher_combined is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        mode : in STD_LOGIC;  -- '0' untuk enkripsi, '1' untuk dekripsi
        input_char : in STD_LOGIC_VECTOR(7 downto 0);  -- Input karakter 8-bit
        processed_char : out STD_LOGIC_VECTOR(7 downto 0)  -- Output karakter terproses
    );
end hill_cipher_combined;

architecture Behavioral of hill_cipher_combined is
    -- Matriks kunci 2x2 untuk enkripsi
    constant ENCRYPT_KEY_MATRIX : STD_LOGIC_VECTOR(15 downto 0) := x"0305"; 

    -- Matriks kunci 2x2 untuk dekripsi
    constant DECRYPT_KEY_MATRIX : STD_LOGIC_VECTOR(15 downto 0) := x"0917"; 

    -- Fungsi untuk mencari modular multiplicative inverse
    function mod_inverse(a : integer; m : integer) return integer is
        variable m0, m_temp : integer := m;
        variable a0 : integer := a;
        variable y : integer := 0;
        variable x : integer := 1;
        variable q, t : integer;
    begin
        if m = 1 then
            return 0;
        end if;

        while a0 > 1 loop
            q := a0 / m0;
            t := m0;

            m0 := a0 mod m0;
            a0 := t;

            t := x;
            x := y - q * x;
            y := t;
        end loop;

        if y < 0 then
            y := y + m;
        end if;

        return y;
    end function;

    -- Fungsi untuk enkripsi single karakter
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

    -- Fungsi untuk dekripsi single karakter
    function decrypt_char(char_val : integer; key_mat : STD_LOGIC_VECTOR(15 downto 0)) return integer is
        variable result : integer;
        variable k11, k12, k21, k22 : integer;
    begin
        -- Ekstrak elemen matriks kunci
        k11 := to_integer(unsigned(key_mat(15 downto 12)));
        k12 := to_integer(unsigned(key_mat(11 downto 8)));
        k21 := to_integer(unsigned(key_mat(7 downto 4)));
        k22 := to_integer(unsigned(key_mat(3 downto 0)));

        -- Dekripsi karakter menggunakan matriks kunci
        result := (k11 * char_val + k12 * char_val) mod 26;
        
        -- Pastikan hasil positif
        if result < 0 then
            result := result + 26;
        end if;

        return result;
    end function;

begin
    process(clk, reset)
        variable char_value : integer range 0 to 25;
        variable processed_value : integer range 0 to 25;
    begin
        if reset = '1' then
            processed_char <= (others => '0');
        elsif rising_edge(clk) then
            -- Proses untuk huruf besar (A-Z)
            if input_char >= x"41" and input_char <= x"5A" then
                char_value := to_integer(unsigned(input_char)) - 65;
                
                -- Pilih mode enkripsi atau dekripsi
                if mode = '0' then
                    processed_value := encrypt_char(char_value, ENCRYPT_KEY_MATRIX);
                else
                    processed_value := decrypt_char(char_value, DECRYPT_KEY_MATRIX);
                end if;
                
                -- Konversi kembali ke karakter ASCII huruf besar
                processed_char <= STD_LOGIC_VECTOR(to_unsigned(processed_value + 65, 8));
            
            -- Proses untuk huruf kecil (a-z)
            elsif input_char >= x"61" and input_char <= x"7A" then
                char_value := to_integer(unsigned(input_char)) - 97;
                
                -- Pilih mode enkripsi atau dekripsi
                if mode = '0' then
                    processed_value := encrypt_char(char_value, ENCRYPT_KEY_MATRIX);
                else
                    processed_value := decrypt_char(char_value, DECRYPT_KEY_MATRIX);
                end if;
                
                -- Konversi kembali ke karakter ASCII huruf kecil
                processed_char <= STD_LOGIC_VECTOR(to_unsigned(processed_value + 97, 8));
            
            -- Jika bukan huruf, kembalikan karakter asli
            else
                processed_char <= input_char;
            end if;
        end if;
    end process;
end Behavioral;