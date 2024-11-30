library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hill_cipher_decrypt is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        encrypted_char : in STD_LOGIC_VECTOR(7 downto 0); -- Input karakter terenkripsi
        decrypted_char : out STD_LOGIC_VECTOR(7 downto 0) -- Output karakter terdekripsi
    );
end hill_cipher_decrypt;

architecture Behavioral of hill_cipher_decrypt is
    -- Matriks kunci 2x2 untuk dekripsi (harus inversnya dari matriks enkripsi)
    constant KEY_MATRIX : STD_LOGIC_VECTOR(15 downto 0) := x"0917"; 
    -- Contoh: [9  23]
    -- [1  7]

    -- Fungsi untuk mencari modular multiplicative inverse
-- Fungsi untuk mencari modular multiplicative inverse
function mod_inverse(a : integer; m : integer) return integer is
    variable m0, m_temp : integer := m;  -- Changed m to m0 as working variable
    variable a0 : integer := a;
    variable y : integer := 0;
    variable x : integer := 1;
    variable q, t : integer;
begin
    if m = 1 then
        return 0;
    end if;

    while a0 > 1 loop
        -- q is quotient
        q := a0 / m0;
        t := m0;

        -- m is remainder now
        m0 := a0 mod m0;
        a0 := t;

        -- Update x and y
        t := x;
        x := y - q * x;
        y := t;
    end loop;

    -- Make x positive
    if y < 0 then
        y := y + m;
    end if;

    return y;
end function;
    -- Fungsi untuk dekripsi single karakter
    function decrypt_char(char_val : integer; key_mat : STD_LOGIC_VECTOR(15 downto 0)) return integer is
        variable k11, k12, k21, k22 : integer;
        variable result : integer;
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
        variable decrypted_value : integer range 0 to 25;
    begin
        if reset = '1' then
            decrypted_char <= (others => '0');
        elsif rising_edge(clk) then
            -- Konversi input karakter ke nilai numerik (A=0, B=1, dst)
            if encrypted_char >= x"41" and encrypted_char <= x"5A" then
                char_value := to_integer(unsigned(encrypted_char)) - 65;
                
                -- Dekripsi karakter
                decrypted_value := decrypt_char(char_value, KEY_MATRIX);
                
                -- Konversi kembali ke karakter ASCII
                decrypted_char <= STD_LOGIC_VECTOR(to_unsigned(decrypted_value + 65, 8));
            elsif encrypted_char >= x"61" and encrypted_char <= x"7A" then
                char_value := to_integer(unsigned(encrypted_char)) - 97;
                
                -- Dekripsi karakter
                decrypted_value := decrypt_char(char_value, KEY_MATRIX);
                
                -- Konversi kembali ke karakter ASCII
                decrypted_char <= STD_LOGIC_VECTOR(to_unsigned(decrypted_value + 97, 8));
            else
                decrypted_char <= encrypted_char;
            end if;
        end if;
    end process;
end Behavioral;