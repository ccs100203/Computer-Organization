main:
    addi $a0, $zero, 10  # n = 10
    addi $a1, $zero, 5  # m = 5
    jal pascal          # call pascal(10, 5)
    j exit

pascal:
    addi $sp, $sp, -16
    sw $ra, 0x0($sp)    # Save $ra register into stack
    sw $t0, 0x4($sp)
    sw $s0, 0x8($sp)
    sw $s1, 12($sp)
	
	addi $v0, $zero, 1
	beq $a0, $a1, L1
	beq $a1, $zero, L1
	addi $s0, $a0, 0
	addi $s1, $a1, 0
	
	#C(n, k-1)
	addi $a0, $s0, -1
	jal pascal
	addi $t0, $v0, 0
	#C(n-1, k-1)
	addi $a0, $s0, -1
	addi $a1, $s1, -1
	jal pascal
	add $v0, $v0, $t0
	
L1: 
    lw $ra, 0x0($sp)    # Load $ra register from stack
    lw $t0, 0x4($sp)
    lw $s0, 0x8($sp)
    lw $s1, 12($sp)
    addi $sp, $sp, 16
    jr $ra

exit:
