library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity TB_UART is 
end entity;


architecture TEST of TB_uart is

    signal clk : std_logic := '0';
    signal TX_Byte: std_logic_vector(7 downto 0) := "00000000";
    signal uart_tx_busy: std_logic; 
    signal uart_tx_data: std_logic;
    signal TX_DV: std_logic; 
    signal RX_DV: std_logic; 
    signal RX_Byte: std_logic_vector(7 downto 0); 

    procedure waitTillUARTReady is
    begin
        wait until(uart_tx_busy='0');
    end procedure;

    procedure waitTillUARTBusy  is
    begin
        wait until(uart_tx_busy = '1'); 
    end procedure;

    procedure waitForClockToFall is
    begin
        wait until(clk'event and clk = '0');
    end procedure;

    procedure waitForClockToRise  is
    begin
        wait until(clk'event and clk='1');
    end procedure;

    procedure waitTillRXValid is
    begin
        wait until(RX_DV = '1'); 
    end procedure; 

    
    component UART_RX is
        generic (
            CLOCKS_PER_BIT: integer := 217
        );
    
        port (
            i_Clock: in std_logic;
            i_RX_Serial: in std_logic;
            o_RX_DV: out std_logic;
            o_RX_Byte: out std_logic_vector(7 downto 0)
        );
    
    end component;

    component UART_TX is

        generic (
            CLOCKS_PER_BIT: integer := 217
        );

        port (
            i_Clock: in std_logic; 
            i_TX_Byte: in std_logic_vector(7 downto 0);
            o_TX_Serial: out std_logic;
            i_TX_DV: in std_logic;
            busy: out std_logic
        );

    end component;


begin

    UART_TX1: UART_TX
        generic map (
            CLOCKS_PER_BIT => 217
        )
        port map (
            i_clock => clk,
            i_TX_Byte => TX_Byte,
            busy => uart_tx_busy,
            o_TX_Serial => uart_tx_data,
            i_TX_DV => TX_DV
        );
    
    UART_RX1: UART_RX
        generic map (
            CLOCKS_PER_BIT => 217
        )

        port map (
            i_Clock => clk,
            i_RX_Serial => uart_tx_data,
            o_RX_DV => RX_DV,
            o_RX_Byte => RX_BYTE
        );


    
    clock_process:
    process
        variable t: time:= 0 ps; 
    begin
        loop 
            t:= t + 100 ps;
            wait for 100 ps;  
            clk <= not clk;
        exit when t >= 100000 ns; 
        
        end loop;
        wait; 
    end process;

    main_process:
    process
        variable data: unsigned (7 downto 0) := "00101010";
    begin
        
        --report "here";
        waitForClockToFall;
        TX_Byte <= std_logic_vector(data); 
        TX_DV <= '1';
        waitForClockToFall;
        data := data + 1; 
        TX_DV <= '0';
        waitTillUARTReady;
        assert TX_Byte = RX_Byte
            report "Transmission error: Received data different from transmitted data"
            severity note;
        

        
        
    end process;

end TEST; 