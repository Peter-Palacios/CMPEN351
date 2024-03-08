.data
prompt1: .asciiz "\nEnter first number: "
prompt2: .asciiz "\nEnter second number: "
prompt3: .asciiz "Enter operator: "
result: .asciiz "Result = "
printRemainder: .asciiz " and remainder = "
invalid1: .asciiz "\nInvalid operator"

.text
.globl main

main:
li $t0, 0 # initialize 
li $t1, 0 # initialize 
li $t2, 0 # initialize 
li $t3, 0 # initialize
li $t4, 0 # initialize 
li $t5, 0 # initialize 
li $t6, 0 # initialize 


#Procedure:  GetInput

#Displays a prompt to the user and then wait for a numerical input

#The user’s input will get stored to the (word) address pointed by $a1

#Input: $a0 points to the text string that will get displayed to the user

#Input: $a1 points to a word address in .data memory, where to store the input number

# Prompt for first number
la $a0, prompt1
jal print_string
li $v0, 5
syscall
move $t0, $v0

#Procedure:  GetOperator

#Displays a prompt to the user and then wait for a single character input

#Input: $a0 points to the text string that will get displayed to the user

#Returns the operator in $v1 (as an ascii character)

# Prompt for operator
la $a0, prompt3
jal print_string
li $v0, 12
syscall
move $t3, $v0

# Prompt for second number
la $a0, prompt2
jal print_string
li $v0, 5
syscall
move $t1, $v0



# Perform calculation based on operator
beq $t3, 43, add
beq $t3, 45, subtract
beq $t3, 42, multiply
beq $t3, 47, divide
j invalid

add:
jal add_numbers
j print_result

subtract:
jal subtract_numbers
j print_result

multiply:
jal multiply_numbers
j print_result

divide:
jal divide_numbers
j print_result

invalid:
la $a0, invalid1
jal print_string
j main

#Procedure:  AddNumb   0($a2) = 0($a0) + 0($a1)

#Add two data values and store the result back to memory

#Input: $a0 points to a word address in .data memory for the first data value

#Input: $a1 points to a word address in .data memory for the second data value

#Input: $a2 points to a word address in .data memory, where to store the result
add_numbers:
add $t2, $t0, $t1
jr $ra

#Procedure:  SubNumb   0($a2) = 0($a0) - 0($a1)

#Subtract two data values and store the result back to memory

#Input: $a0 points to a word address in .data memory for the first data value

#Input: $a1 points to a word address in .data memory for the second data value

#Input: $a2 points to a word address in .data memory, where to store the result
subtract_numbers:
sub $t2, $t0, $t1
jr $ra

#Procedure:  MultNumb   0($a2) = 0($a0) * 0($a1)

#Multiply two data values and store the result back to memory

#Input: $a0 points to a word address in .data memory for the first data value

#Input: $a1 points to a word address in .data memory for the second data value

#Input: $a2 points to a word address in .data memory, where to store the result
multiply_numbers:

# Repeat the loop for each bit of the second number
mult_loop:
beq $t1, 0, mult_end # if second number is 0, end loop
and $t3, $t1, 1 # check the least significant bit of the second number
beq $t3, 0, mult_shift # if bit is 0, shift second number and add 0 to result
add $t2, $t2, $t0 # if bit is 1, add first number to result

mult_shift:
srl $t1, $t1, 1 # shift second number to the right by 1
sll $t0, $t0, 1 # shift first number to the left by 1
j mult_loop

mult_end:
jr $ra

#Procedure:  DivNumb   0($a2) = 0($a0) / 0($a1)   0($a3) = 0($a0) % 0($a1)

#Divide two data values and store the result back to memory

#Input: $a0 points to a word address in .data memory for the first data value

#Input: $a1 points to a word address in .data memory for the second data value

#Input: $a2 points to a word address in .data memory, where to store the quotient

#Input: $a3 points to a word address in .data memory, where to store the remainder
divide_numbers:


move $a0, $t0
move $a1, $t1

add $v0, $0, $0			# 9/3=3 -> 9= divident, 3=divisor 3=quotient(answer) remainded=0
add $t5, $a1, $0			#dividend = a0
					#divisor = a1
oloop: add $t5, $a1, $0			#rquotient=v0
	add $t6, $0, 1			#tempdivisor=t1
					#tempquotient=t2
inloop: sll $t6, $t6, 1			#branch flag= t0
	sll $t5, $t5, 1
	sltu $0, $a0, $t5
	bne $t4, $zero, inloop
	
	addu $v0, $v0, $t6
	srl $t5, $t5, 1				#quotient stored in $v0
	sub $a0, $a0, $t5			#remainded stored in $a0
	sltu $t4, $a0, $a1
	beq $t4, $0, oloop
	
	srl $v0, $v0, 1	
	
	move $t2, $v0
	move $t4, $a0
	jr $ra

#Procedure: DisplayNumb

#Displays a message to the user followed by a numerical value

#Input: $a0 points to the text string that will get displayed to the user

#Input: $a1 points to a word address in .data memory, where the input value is stored

print_string:
li $v0, 4
syscall
jr $ra

print_result:
# Display result
la $a0, result
jal print_string
move $a0, $t2
li $v0, 1
syscall

bgtz $t4, print_remainder

# Prompt for new calculation
j main

print_remainder:
la $a0, printRemainder
jal print_string
move $a0, $t4
li $v0, 1
syscall

j main