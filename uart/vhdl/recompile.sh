#!/usr/bin/bash


ghdl -a uart_tx.vhd
ghdl -e uart_tx
ghdl -r uart_tx

ghdl -a TB_uart.vhd
ghdl -e TB_uart
ghdl -r TB_uart --wave=uart.ghw

