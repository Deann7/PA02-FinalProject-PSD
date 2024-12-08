library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hillCipher is
    Port (
        input  : in STD_LOGIC_VECTOR(7 downto 0);
        mode   : in STD_LOGIC;
        output : out STD_LOGIC_VECTOR(7 downto 0)
    );
end hillCipher;

architecture Behavioral of hillCipher is
    constant KEY_MATRIX : STD_LOGIC_VECTOR(15 downto 0) := x"0405";
    function mod_inverse(a : integer; m : integer) return integer is
        variable m0, y, x : integer;
        variable a0 : integer := a;
        variable m1 : integer := m;
    begin
        m0 := m;
        y := 0;
        x := 1;
        if m = 1 then
            return 0;
        end if;
        while a0 > 1 loop
            x := x - (m0 / a0) * y;
            m1 := m0 mod a0;
            m0 := a0;
            a0 := m1;
            a0 := x;
            x := y;
            y := a0;
        end loop;
        if x < 0 then
            x := x + m;
        end if;
        return x;
    end function;
    function mod26(value : integer) return integer is
    begin
        return (value mod 26 + 26) mod 26;
    end function;
begin
    process(input, mode)
        variable temp_value : integer;
        variable processed_value : integer;
        variable det : integer;
        variable det_inv : integer;
    begin
        if (input >= x"41" and input <= x"5A") or (input >= x"61" and input <= x"7A") then
            if input >= x"61" then
                temp_value := to_integer(unsigned(input)) - 97;
            else
                temp_value := to_integer(unsigned(input)) - 65;
            end if;
            det := mod26(
                to_integer(unsigned(KEY_MATRIX(15 downto 8))) *
                to_integer(unsigned(KEY_MATRIX(7 downto 0))) -
                to_integer(unsigned(KEY_MATRIX(15 downto 0))) *
                to_integer(unsigned(KEY_MATRIX(7 downto 0)))
            );
            det_inv := mod_inverse(det, 26);
            if mode = '0' then
                processed_value := mod26(
                    (to_integer(unsigned(KEY_MATRIX(15 downto 8))) * temp_value +
                     to_integer(unsigned(KEY_MATRIX(7 downto 0))) * temp_value)
                );
            else
                processed_value := mod26(
                    det_inv * (
                        to_integer(unsigned(KEY_MATRIX(7 downto 0))) * temp_value -
                        to_integer(unsigned(KEY_MATRIX(15 downto 8))) * temp_value
                    )
                );
            end if;
            if input >= x"61" then
                output <= std_logic_vector(to_unsigned(processed_value + 97, 8));
            else
                output <= std_logic_vector(to_unsigned(processed_value + 65, 8));
            end if;
        else
            output <= input;
        end if;
    end process;
end Behavioral;
