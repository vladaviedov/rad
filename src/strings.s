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

.section .text

minutes:
	.ascii "Minutes: "
.equ minutes_length, . - minutes
.equ minutes_pos, 0

cpm:
	.ascii "CPM: "
.equ cpm_length, . - cpm
.equ cpm_pos, 64

total:
	.ascii "Total: "
.equ total_length, . - total
.equ total_pos, 20

.end
