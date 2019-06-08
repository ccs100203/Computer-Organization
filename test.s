#Print a integer
.data
      age: .word 32
.text
  #print an integer to the screen
  li $v0, 1
  lw $a0, age
  li $a1, 20
  li $v0 5
  syscall
