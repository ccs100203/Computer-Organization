main:
    addi $a0, $zero, 10 # n = 10
    addi $a1, $zero, 5 # m = 5
    jal pascal          # call pascal(10, 5)
    j exit

pascal:

 
    #--------------------------------------#
    #  \^o^/   Write your code here~  \^o^/#
    #--------------------------------------#
	beq $a0,$a1,return1   #m==n
    beq $zero,$a1,return1  #m==0    
    addi $sp, $sp, -12
    sw $ra  0($sp)	 #save $ra into stack
    sw $a0  4($sp)   #save n into stack
	sw $a1  8($sp)   #save m into stack  

	addi $a0,$a0,-1     #n-1
	jal pascal			#pascal(n-1,m)
	addi $a1,$a1,-1     #m-1
	jal pascal 			  #pascal(n-1,m-1)
	
	lw $ra 0($sp)           
	lw $a0 4($sp)
	lw $a1 8($sp)   
    addi $sp, $sp, 12
    jr $ra

return1:
	addi $v0 $v0 1
	jr $ra
exit:
	
