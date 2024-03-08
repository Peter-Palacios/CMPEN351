.data
prompt1: .asciiz "\nEnter first number: "
prompt2: .asciiz "\nEnter second number: "
prompt3: .asciiz "Enter operator: "
result: .asciiz "Result = "
printRemainder: .asciiz " and remainder = "
invalid1: .asciiz "\nInvalid operator"

buffer: .byte 0:80
decimal: .asciiz "."
OutofRange: .asciiz "Error: number is out of range (not 0-9)"
#dollars_and_cents .asciiz 

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
li $v0, 8
la $a0, buffer
la $a1, 80
syscall
la $a0, buffer
li $t4, 0
beqz $t4, GetInput


#Procedure:  GetOperator

#Displays a prompt to the user and then wait for a single character input

#Input: $a0 points to the text string that will get displayed to the user

#Returns the operator in $v1 (as an ascii character)

# Prompt for operator
Operator:
move $t5, $t0 #set contents temporarily to $t5 from number1
la $a0, prompt3
jal print_string
li $v0, 12
syscall
move $t6, $v0

# Prompt for second number
la $a0, prompt2
jal print_string
li $v0, 8
la $a0, buffer
la $a1, 80
syscall
la $a0, buffer
li $t4, 1


#Procedure: GetInput

#Takes string input of user and converts to ingteger

GetInput:
    # Load the addresses
    #la $a0, dollars_and_cents
    
    # Loop until decimal 
    li $t0, 0
    li $t1, 0
    loop:
        lbu $t2, 0($a0)
        beq $t2, 0x2e, done_loop
        subi $t2, $t2, 48  # Convert to integer
        mul $t0, $t0, 10
        add $t0, $t0, $t2
        addi $a0, $a0, 1
        j loop
    done_loop:

    # Loop after decimal point
    li $t1, 0
    li $t3, 10
    lbu $t2, 0($a0)
    addi $a0, $a0, 1
    loop2:
        lbu $t2, 0($a0)
        addi $a0, $a0, 1
        subi $t2, $t2, 48  # Convert to integer
        mul $t2, $t2, $t3  # need to multiply by 10 and add to cents conversion
        add $t1, $t1, $t2
        div $t3, $t3, 10   # change to add pennies in next loop
          
    loop3:
   	lbu $t2, 0($a0)
        addi $a0, $a0, 1
    	beq $t2, '\0', done_loop2
        subi $t2, $t2, 48  
        div $t2, $t2, $t3  # Divide by 10
        add $t1, $t1, $t2
        div $t3, $t3, 10   
    done_loop2:
    # Combine dollars and cents into a single integer
    li $t2, 100
    mul $t0, $t0, $t2
    add $t0, $t0, $t1
   beqz $t4, Operator
  GetNumber2:
      move $t1, $t0
      move $t0, $t5
    # Store the result in the "result" variable
    #sw $t0, result

# Perform calculation based on operator
beq $t6, 43, add
beq $t6, 45, subtract
beq $t6, 42, multiply
beq $t6, 47, divide
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


#Procedure: print_result

#Displays result as a decimal


print_result:
# Display result

li $t3, 0
li $t4, 0
li $t5, 0
li $t6, 0

move $t0, $t2
li $t1, 100

div $t2, $t0, $t1
rem $t3, $t0, $t1

li $v0, 1
move $a0, $t2
syscall

li $v0, 4
la $a0,decimal
syscall

li $t1, 10

div $t4, $t3, $t1
rem $t5, $t3, $t1

li $v0, 1
move $a0, $t4
syscall

li $v0, 1
move $a0, $t5
syscall


li $v0, 8
la $a0, buffer
la $a1, 80
syscall

#buffer: .byte 0:80 -- put inside .data on top

la $a0, buffer
li $a1, 80

#convert ascii to integer

la $a0, buffer

#loops until reaches end of dollars
loop1:
lb $t1, 0($a0)
addiu $a0, $a0, 1
li $t2, 0xA
#breaks if reaches 10s or null in dollars place
beq $t1, $t2, break1
beq $t1, $0, break1

#also breaks if dollar character is '.'
li $t2, 0x2e
beq $t1, $t2, break1
#!!!! Error check: see if $t1 is in right range 0x30- 0x39 else error
li $t7, 0x29
bge $t1, $t7, RangeError 
li $t7, 0x40
ble $t1, $t6, RangeError
#Set dat from ascii 0-9 to binary 0-9
sub $t3, $t1, 0x30
#!!!! Error check: see if $t3 is in right range 0x30- 0x39 else error
mul $t0, $t0, 10
add $t0, $t0, $t3
bnez $t1, loop1 #loops back if $t1 not 0

break1:
#convert numbers to dollars
mul $t0, $t0, 100


li $t2, 0x2e
bne $t1, $t2, break2

#convert Dimes
lb $t1, 0($a0)
addiu $a0, $a0, 1

#!!! see if ascii is 0-9 (error check)

#convert (again to binary)

sub $t3, $t1, 0x30

#if tens digit, mult by 10 and add to dollar amount

mul $t6, $t3, 10
add $t0, $t6, $t0

#convert Pennies
lb $t1, 0($a0)
addiu $a0, $a0, 1

sub $t3, $t1, 0x30

add $t0, $t0, $t3

break2:
li $v0, 1
move $a0, $t2
syscall

li $v0, 4
la $a0,decimal
syscall

#Call Error
RangeError:
li $v0, 4
la $a0, OutofRange
syscall	


j main

print_remainder:
la $a0, printRemainder
jal print_string
move $a0, $t4
li $v0, 1
syscall

j main
