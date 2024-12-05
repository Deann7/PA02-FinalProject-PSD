library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hillCipher is
    port (
        input  : in STD_LOGIC_VECTOR(7 downto 0);
        mode   : in STD_LOGIC;  -- 0 for forward process, 1 for reverse
        output : out STD_LOGIC_VECTOR(7 downto 0)
    );
end entity hillCipher;

architecture Behavioral of hillCipher is
    -- Matriks kunci 2x2 untuk Hill Cipher
    type matrix_2x2 is array(0 to 1, 0 to 1) of integer;
    constant KEY_MATRIX : matrix_2x2 := ((3, 2), (2, 5));
    constant DET_KEY : integer := 3 * 5 - 2 * 2;
    constant DET_INV : integer := 17;  -- Inverse dari determinan

    function mod26(x : integer) return integer is
    begin
        return ((x mod 26 + 26) mod 26);
    end function;

begin
    process(input, mode)
        variable char_value : integer range 0 to 255;
        variable transformed_1 : integer;
    begin
        char_value := to_integer(unsigned(input));

        if char_value >= 65 and char_value <= 90 then
            if mode = '0' then  -- Forward process (Encrypt)
                transformed_1 := mod26(KEY_MATRIX(0,0) * (char_value - 65) + KEY_MATRIX(0,1) * (char_value - 65));
                output <= std_logic_vector(to_unsigned(transformed_1 + 65, 8));
            else  -- Reverse process (Decrypt)
                transformed_1 := mod26(DET_INV * (KEY_MATRIX(1,1) * (char_value - 65) - KEY_MATRIX(0,1) * (char_value - 65)));
                output <= std_logic_vector(to_unsigned(transformed_1 + 65, 8));
            end if;
        elsif char_value >= 97 and char_value <= 122 then
            if mode = '0' then  -- Forward process (Encrypt)
                transformed_1 := mod26(KEY_MATRIX(0,0) * (char_value - 97) + KEY_MATRIX(0,1) * (char_value - 97));
                output <= std_logic_vector(to_unsigned(transformed_1 + 97, 8));
            else  -- Reverse process (Decrypt)
                transformed_1 := mod26(DET_INV * (KEY_MATRIX(1,1) * (char_value - 97) - KEY_MATRIX(0,1) * (char_value - 97)));
                output <= std_logic_vector(to_unsigned(transformed_1 + 97, 8));
            end if;
        else
            output <= input;
        end if;
    end process;
end architecture Behavioral;