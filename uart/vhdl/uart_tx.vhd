-- This transmitter draws inspiration from the Nandland implementation
-- of a UART receiver: https://edaplayground.com/x/4Lyz


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity UART_TX is
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
end entity;


architecture RLT of UART_TX is

    type UART_TX_STATE is (IDLE,
                        TX_START_BIT,
                        TX_DATA_BITS,
                        TX_STOP_BIT,
                        CLEANUP);

    signal r_TX_STATE: UART_TX_STATE;
    signal r_Clock_Count: integer;
    signal r_TX_Bit_Index: integer range 0 to 7;
    signal r_TX_Bit: std_logic;
    signal r_TX_Byte: std_logic_vector(7 downto 0);
    signal r_Received: std_logic; 
    

begin

    o_TX_Serial <= r_TX_Bit; 


    process (i_Clock)
    begin
        
        case r_TX_STATE is
            when IDLE =>
                r_Clock_Count <= 0; 
                r_TX_Bit_Index <= 0;
                r_TX_Bit <= '1'; 

                if (i_TX_DV = '1') then
                    r_TX_STATE <= TX_START_BIT;
                    r_TX_Byte <= i_TX_Byte; 
                end if; 

            when TX_STOP_BIT =>
                -- transmit '1' for 1 bit length; 
                if (r_Clock_Count < (CLOCKS_PER_BIT-1)) then
                    r_Clock_Count <= r_Clock_Count + 1;
                
                else
                    r_Clock_Count <= 0;
                    if (i_TX_DV = '1') then
                        r_Received <= '1'; 
                        r_TX_STATE <= TX_START_BIT; 
                        r_TX_Byte <= i_TX_Byte;
                    else
                        r_TX_STATE <= IDLE; 
                    end if; 
            
                end if; 


    
            when TX_START_BIT =>
                -- Transmit '0' for one bit length
                r_Received <= '0';
                if (r_Clock_Count < (CLOCKS_PER_BIT-1)) then
                    r_TX_Bit <= '0';
                    r_Clock_Count <= r_Clock_Count + 1; 
                    r_TX_STATE <= TX_START_BIT;
                else
                    r_Clock_Count <= 0; 
                    r_TX_STATE <= TX_DATA_BITS;
                    r_TX_Bit_Index <= 0; 
            
                end if; 
            
            when TX_DATA_BITS =>
                -- Transmit data bits;
                -- Takes 8 * CLOCKS_PER_BIT CLOCK CYCLES
                if (r_Clock_Count < (CLOCKS_PER_BIT)) then
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_TX_Bit <= r_TX_Byte(r_TX_Bit_Index); 
                
                else
                    r_Clock_Count <= 0;

                    if (r_TX_Bit_Index < 7) then
                        r_TX_Bit_Index <= r_TX_Bit_Index + 1;
                    else
                        -- Data transmission completed, movet to TX_STOP_STATE; 
                        r_TX_STATE <= TX_STOP_BIT;
                        r_TX_Bit_Index <= 0; 
                    end if; 
                end if;

            when others =>
                r_TX_STATE <= IDLE;
        end case;
    end process;

    process (i_clock)
    begin
        if rising_edge(i_clock) then
            case r_TX_STATE is  
                when IDLE =>
                    busy <= '0';
                
                when TX_STOP_BIT =>
                    if (r_Received = '1') then
                        busy <= '1';
                    else
                        busy <= '0';
                    end if; 

                when others => 
                        busy <= '1';
                
            end case; 

        end if;
    end process;

end architecture;