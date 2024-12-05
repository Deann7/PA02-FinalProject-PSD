library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity caesarCipher is
    port (
        input       : in  std_logic_vector(7 downto 0);
        cipher      : out std_logic_vector(7 downto 0)
    );
end entity caesarCipher;

architecture Behavioral of caesarCipher is
    constant SHIFT_VALUE : integer := 3;
begin
    process(input)
        variable temp : integer;
    begin
        temp := to_integer(unsigned(input)); 

        if (temp >= 65 and temp <= 90) then
            temp := ((temp - 65 + SHIFT_VALUE) mod 26) + 65;
        elsif (temp >= 97 and temp <= 122) then
            temp := ((temp - 97 + SHIFT_VALUE) mod 26) + 97;
        end if;

        cipher <= std_logic_vector(to_unsigned(temp, 8));
    end process;
end architecture Behavioral;