library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity UART_RX is
    generic (
        CLOCKS_PER_BIT: integer := 217
    );

    port (
        i_Clock: in std_logic;
        i_RX_Serial: in std_logic;
        o_RX_DV: out std_logic;
        o_RX_Byte: out std_logic_vector(7 downto 0)
    );

end entity; 

architecture RTL of UART_RX is

    type RX_STATE is (IDLE, -- waiting for start bit
                    RX_START_BIT, -- start bit detected
                    RX_DATA_BITS, -- receiving data bits
                    RX_STOP_BIT, -- stop bit
                    CLEANUP);


    signal r_Clock_Count: std_logic_vector(7 downto 0);
    signal r_Bit_Index: integer range 0 to 7; --index of bit to write to
    signal r_RX_Byte: std_logic_vector(7 downto 0); -- hold data while receiving
    signal r_RX_DV: std_logic; -- falling edge indicates data is valid (all bits have being received)
    signal r_RX_STATE: RX_STATE; -- current state of the UART

        
begin

    process (i_Clock)
    begin
        if rising_edge(i_Clock) then
            case r_RX_STATE is  
                when IDLE =>
                    r_RX_DV <= 0;
                    if (i_RX_Serial = '0') then
                        r_RX_STATE <= RX_START_BIT;
                        r_Clock_Count <= '1'; 
                    else
                        r_RX_STATE <= IDLE;
                    end if;

                when RX_START_BIT =>
                    r_RX_DV <= 0;
                    if (r_Clock_Count = (CLOCKS_PER_BIT)/2) then
                        if (i_RX_Serial = '0') then
                            r_Clock_Count <= 0;
                            r_RX_STATE <= RX_DATA_BITS;
                        else
                            r_RX_STATE <= IDLE;
                        end if; 
                    else
                        r_Clock_Count <= r_Clock_Count + 1;
                        r_RX_STATE <= RX_START_BIT;
                    end if;
                    
                when RX_DATA_BITS =>
                    if (r_Clock_Count < CLOCKS_PER_BIT - 1) then
                        r_Clock_Count <= r_Clock_Count + 1;
                        r_RX_STATE <= RX_DATA_BITS;
                    else
                        r_Clock_Count <= 0;
                        r_RX_Byte(r_Bit_Index) <= i_RX_Serial;

                        if (r_Bit_Index < 7) then
                            r_Bit_Index <= r_Bit_Index + 1;
                            r_RX_STATE <= RX_DATA_BITS; 
                        else
                            r_Bit_Index <= 0;
                            r_RX_STATE <= RX_STOP_BIT;
                        end if;

                    end if;

                
                when RX_STOP_BIT => 
                    if (r_Clock_Count < CLOCKS_PER_BIT) then
                        r_Clock_Count <= r_Clock_Count + 1;
                        r_RX_STATE <= RX_STOP_BIT;
                    else
                        r_RX_DV <= '1';
                        r_Clock_Count <= 0; 
                        r_RX_STATE <= CLEANUP;
                    end if;

                
                when CLEANUP => 
                    r_RX_STATE <= IDLE;
                    r_RX_DV <= '0'; -- FALLING CLOCK EDGE TO INDICATE VALID DATA ON OUTPUT
                
                when others =>
                    r_RX_STATE <= IDLE; 

                end case; 
        end if;
    end process;

    

end architecture;