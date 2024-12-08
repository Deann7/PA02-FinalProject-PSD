library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity caesarChiper is
    port (
        input       : in  std_logic_vector(7 downto 0);
        mode        : in  std_logic;  -- '0' for encrypt, '1' for decrypt
        shift_char  : in  integer range 0 to 25;
        cipher      : out std_logic_vector(7 downto 0)
    );
end entity caesarChiper;

architecture Behavioral of caesarChiper is
begin
    process(input, mode, shift_char)
        variable temp : integer range 0 to 255;
        variable actual_shift : integer range -25 to 25;
    begin
        -- Convert input to integer
        temp := to_integer(unsigned(input));
        
        -- Determine shift direction based on mode
        if mode = '0' then  -- Encrypt
            actual_shift := shift_char;
        else  -- Decrypt
            actual_shift := -shift_char;
        end if;
        
        -- Uppercase letters (A-Z)
        if (temp >= 65 and temp <= 90) then
            temp := ((temp - 65 + actual_shift + 26) mod 26) + 65;
        
        -- Lowercase letters (a-z)
        elsif (temp >= 97 and temp <= 122) then
            temp := ((temp - 97 + actual_shift + 26) mod 26) + 97;
        end if;
        
        -- Convert back to std_logic_vector
        cipher <= std_logic_vector(to_unsigned(temp, 8));
    end process;
end architecture Behavioral;