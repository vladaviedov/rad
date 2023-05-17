.syntax unified
.cpu cortex-m0
.thumb

.global minutes
.global minutes_length
.global minutes_pos
.global cpm
.global cpm_length
.global cpm_pos
.global total
.global total_length
.global total_pos
.global avg_cpm
.global avg_cpm_length
.global avg_cpm_pos

.section .text

minutes:
	.ascii "Minutes:"
.equ minutes_length, . - minutes
.equ minutes_pos, 0

cpm:
	.ascii "CPM:"
.equ cpm_length, . - cpm
.equ cpm_pos, 64

avg_cpm:
	.ascii "Avg CPM:"
.equ avg_cpm_length, . - avg_cpm
.equ avg_cpm_pos, 20

total:
	.ascii "Total:"
.equ total_length, . - total
.equ total_pos, 84

.end
