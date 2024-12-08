library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity MainTB is
end MainTB;

architecture Behavioral of MainTB is
    -- Komponen yang akan diuji
    component Main
        Port (
            clk         : in STD_LOGIC;
            rst         : in STD_LOGIC;
            mode        : in STD_LOGIC;
            start       : in STD_LOGIC;
            done_out    : out STD_LOGIC;
            error_out   : out STD_LOGIC
        );
    end component;

    -- Sinyal untuk testbench
    signal clk         : STD_LOGIC := '0';
    signal rst         : STD_LOGIC := '1';
    signal mode        : STD_LOGIC := '0';
    signal start       : STD_LOGIC := '0';
    signal done_out    : STD_LOGIC;
    signal error_out   : STD_LOGIC;

    -- Konstanta untuk clock period
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instansiasi Unit Under Test (UUT)
    uut: Main PORT MAP (
        clk => clk,
        rst => rst,
        mode => mode,
        start => start,
        done_out => done_out,
        error_out => error_out
    );

    -- Proses pembangkit clock
    clk_process: process
    begin
        while now < 1000 ns loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Proses stimuli
    stim_process: process
        file check_file : text;
        variable line_check : line;
        variable test_line : line;
    begin
        -- Inisialisasi file input untuk tes
        file_open(check_file, "input.txt", read_mode);
        
        -- Reset awal
        rst <= '1';
        mode <= '0';
        start <= '0';
        wait for CLK_PERIOD*2;
        
        -- Lepas reset
        rst <= '0';
        
        -- Proses enkripsi (mode = 0)
        mode <= '0';
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        
        -- Tunggu proses selesai
        wait until done_out = '1';
        
        -- Tunggu sejenak
        wait for CLK_PERIOD*2;
        
        -- Proses dekripsi (mode = 1)
        mode <= '1';
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        
        -- Tunggu proses selesai
        wait until done_out = '1';
        
        -- Tutup file
        file_close(check_file);
        
        -- Selesaikan simulasi
        wait;
    end process;

    -- Proses verifikasi (opsional)
    verify_process: process
        file verify_input_file : text;
        file verify_decrypt_file : text;
        variable line_input, line_decrypt : line;
        variable input_char, decrypt_char : character;
        variable input_ok : boolean := true;
    begin
        wait until done_out = '1';
        
        -- Buka file untuk verifikasi
        file_open(verify_input_file, "input.txt", read_mode);
        file_open(verify_decrypt_file, "decryptOutput.txt", read_mode);
        
        -- Bandingkan karakter per karakter
        while not endfile(verify_input_file) and not endfile(verify_decrypt_file) loop
            readline(verify_input_file, line_input);
            readline(verify_decrypt_file, line_decrypt);
            
            read(line_input, input_char);
            read(line_decrypt, decrypt_char);
            
            -- Lakukan pengecekan
            assert input_char = decrypt_char 
            report "Karakter tidak cocok: input = " & input_char & ", decrypt = " & decrypt_char 
            severity failure;
        end loop;
        
        -- Tutup file
        file_close(verify_input_file);
        file_close(verify_decrypt_file);
        
        wait;
    end process;

end Behavioral;