library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity caesarChiper is
    port (
        input       : in  std_logic_vector(7 downto 0);
        shift_char  : in  integer range 0 to 25;
        cipher      : out std_logic_vector(7 downto 0)
    );
end entity caesarChiper;

architecture Dataflow of caesarChiper is
begin

    process(input, shift_char)
        variable temp : integer;
    begin
        temp := conv_integer(input); 

        -- Huruf Kapital (A-Z)
        if (temp >= 65 and temp <= 90) then
            temp := ((temp - 65 + shift_char) mod 26) + 65;
        -- Huruf Kecil (a-z)
        elsif (temp >= 97 and temp <= 122) then
            temp := ((temp - 97 + shift_char) mod 26) + 97;
        end if;

        -- Konversi integer kembali ke std_logic_vector
        cipher <= conv_std_logic_vector(temp, 8);
        


    end process;
end architecture Dataflow;