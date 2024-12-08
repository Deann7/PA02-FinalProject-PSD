library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hillCipher is
    Port (
        input : in STD_LOGIC_VECTOR(7 downto 0);
        mode  : in STD_LOGIC;  -- 0 for encryption, 1 for decryption
        output : out STD_LOGIC_VECTOR(7 downto 0)
    );
end hillCipher;

architecture Behavioral of hillCipher is
    -- 2x2 Hill Cipher Key Matrix
    type matrix is array (0 to 1, 0 to 1) of integer range 0 to 25;
    constant key : matrix := ((3, 2), (5, 7));
    constant det_inv : integer := 15;  -- Modular multiplicative inverse of determinant

    -- Function now takes mode as a parameter
    function matrixMultiply(
        char : integer; 
        processing_mode : STD_LOGIC
    ) return integer is
        variable result : integer range 0 to 25;
        variable vec : matrix;
    begin
        -- Convert character to 2D vector
        vec(0,0) := char;
        vec(0,1) := 0;

        if processing_mode = '0' then  -- Encryption
            result := (key(0,0) * vec(0,0) + key(0,1) * vec(0,1)) mod 26;
        else  -- Decryption
            result := (det_inv * ((7 * vec(0,0) - 2 * vec(0,1)) mod 26)) mod 26;
        end if;

        return result;
    end function;

begin
    process(input, mode)
        variable temp : integer range 0 to 255;
    begin
        temp := to_integer(unsigned(input));

        -- Only process alphabetic characters
        if (temp >= 65 and temp <= 90) then  -- Uppercase
            temp := matrixMultiply(temp - 65, mode) + 65;
        elsif (temp >= 97 and temp <= 122) then  -- Lowercase
            temp := matrixMultiply(temp - 97, mode) + 97;
        end if;

        output <= std_logic_vector(to_unsigned(temp, 8));
    end process;
end Behavioral;