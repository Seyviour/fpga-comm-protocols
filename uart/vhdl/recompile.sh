#!/usr/bin/bash


ghdl -a uart_tx.vhd
ghdl -e uart_tx
ghdl -r uart_tx

ghdl -a uart_rx.vhd
ghdl -e uart_rx
ghdl -r uart_rx

ghdl -a TB_uart.vhd
ghdl -e TB_uart
ghdl -r TB_uart --wave=uart.ghw

