# Entity: UART_TX 

- **File**: uart_tx.vhd
## Diagram

![Diagram](uart_vhdl_tx.svg "Diagram")
## Generics

| Generic name   | Type    | Value | Description |
| -------------- | ------- | ----- | ----------- |
| CLOCKS_PER_BIT | integer | 217   |             |
## Ports

| Port name   | Direction | Type                         | Description |
| ----------- | --------- | ---------------------------- | ----------- |
| i_Clock     | in        | std_logic                    |             |
| i_TX_Byte   | in        | std_logic_vector(7 downto 0) |             |
| o_TX_Serial | out       | std_logic                    |             |
| i_TX_DV     | in        | std_logic                    |             |
## Signals

| Name           | Type                         | Description |
| -------------- | ---------------------------- | ----------- |
| r_TX_STATE     | UART_TX_STATE                |             |
| r_Clock_Count  | integer                      |             |
| r_TX_Bit_Index | integer range 0 to 7         |             |
| r_TX_Bit       | std_logic                    |             |
| r_TX_Byte      | std_logic_vector(7 downto 0) |             |
## Types

| Name          | Type                                                                                                                                                                                                     | Description |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| UART_TX_STATE | (IDLE,<br><span style="padding-left:20px"> TX_START_BIT,<br><span style="padding-left:20px"> TX_DATA_BITS,<br><span style="padding-left:20px"> TX_STOP_BIT,<br><span style="padding-left:20px"> CLEANUP) |             |
## Processes
- unnamed: ( i_Clock )
## State machines

![Diagram_state_machine_0]( stm_uart_tx_0.svg "Diagram")