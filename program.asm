########################################
# Shumba Brown -- 11/09/17
# program.asm - Converts a hexadecimal to a decimal number.


# $s0 - Address of first character in input.
# $s1 - Address of start of current string.
# $s2 - Address of end of current string.
# $s3 - Track the length of the current string.
# $t3 - Track current byte.
# $t4 - Track the length
# $t5 - Track index
# $s4 - Hold sum
# $s5 - total sum

# $s4 - Used to store the validity of the current string. 1 - NaN, 2 - Too long, 3 - Valid decimal

.data
    input: .space 10001
    input_prompt:  .asciiz "Enter a hexadecimal number: "
    error_NaN:  .asciiz "\nNaN"
    error_too_long: .asciiz "\nToo long"
    new_line: .asciiz "\n"
    output_string: .asciiz "\nThe decimal number is: "
.text


main:
    jal get_input

main_loop:

    jal find_next_start_end
    
    add $s0, $zero, $v0                 # Store start pointer.
    add $s1, $zero, $v1                 # Store end pointer.
    
    # set register args for determine_validity
    add $a0, $zero, $v0                 # Set $a0 to start pointer.
    add $a1, $zero, $v1                 # Set $a1 to end pointer.
    
    jal determine_validity 
    
    # Store validity and length
    add $s2, $zero, $v0                 # Store validity of string.
    add $s3, $zero, $v1                 # Store length of string.
    
    # Set register args for subprogram_2
    add $a0, $zero, $s0                 # Set $a0 to start pointer.
    add $a1, $zero, $s1                 # Set $a1 to end pointer.
    add $a2, $zero, $s3                 # Set $a2 to length of string.
    add $a3, $zero, $s2                 # set $a3 to validity of string.
    jal subprogram_2
    
    
    # Set register args for subprogram_3
    add $a0, $zero, $s2                 # Set $a0 to validity of string.
    jal subprogram_3                    
    
    addi $a0, $s1, 1                    # Set start pointer to be end pointer.
    j main_loop
    
    
  end_program:
    li $v0, 10                          # End program.
    syscall


  get_input:
    la $a0, input_prompt                
    li $v0, 4
    syscall                             # Print input prompt.

    la $a0, input                                                                                 
    li $a1, 1000                                                                
    li $v0, 8                                                                 
    syscall                             # Accept input.
    
    jr $ra


########################################
# find_next_start_end

# Finds the start and end of a string.
#
# Arg registers used: 
# $a0 - Pointer to start of string.
#
# Tmp registers used: 
# $t0 - current location
# $t1 - byte at current position
# $t2 - end of string
# Return registers used:
# $v0 - Pointer to start of string
# $v1 - Pointer to end of string

# Pre: none
# Post: $v0 contains the return value.
# Returns: the decimal value of the character in $a2 that is at the $a1 index
# in a string that is $a0 long.
# Called by: subprogram_2
# Calls: none
    
find_next_start_end:
    add $t0, $zero, $a0                 # Set $t0 to start of string.

  find_start:  
    lb $t1, 0($t0)                      # Load the character at the start.
    beq $t1, 10, end_program            # If character is a newline, end program.
    beq $t1, 0, end_program             # If character is null, end program.
    beq $t1, 32, increment_start_pointer# If character is space, shift right.
    beq $t1, 44, increment_start_pointer# If character is comma, shift right.
  
    addi $t2, $t0, 1                    # Set end pointer to start pointer + 1.
    
  find_comma:
    lb $t1, 0($t2)                      # Load the character at the end.
    beq $t1, 10, step_back              # If character is a new line, step back.
    beq $t1, 0, step_back               # If character is a null, step back.
    bne $t1, 44, increment_end_pointer  # If character is not a comma, step forward.
  
    addi $t2, $t2, -1                   # Decrement the end pointer.
    
  step_back:
    lb $t1, 0($t2)                      # Load character at end pointer.
    beq $t1, 32, decrement_end_pointer         
    beq $t1, 0, decrement_end_pointer
    beq $t1, 10, decrement_end_pointer

    add $v0, $zero, $t0                 # Set $v0 to start pointer.
    add $v1, $zero, $t2                 # Set $v1 to end pointer.
    jr $ra

  increment_start_pointer:
    addi $t0, $t0, 1                    # Increment start pointer. 
    j find_start

  increment_end_pointer:
    addi $t2, $t2, 1                    # Increment end pointer.
    j find_comma

  decrement_end_pointer:
    addi $t2, $t2, -1                   # Decrement end pointer.
    j step_back


    
########################################
# determine_validity
# Determine if a string is a valid hex less than 9 characters, a valid hex
# greater than 9 characters or an invalid hex.
#
# Arg registers used: 
# $a0 - Pointer to start of string.
# $a1 - Pointer to end of string.
#
# Tmp registers used: 
# $t0 - Pointer to current position.
# $t1 - Byte at current position.
# $t2 - Index of current character.
#
# Return registers used:
# $v0 - validity of string.
#
# Pre: none
# Post: $v0 contains the return value, $v1 contains the length of the string
# Returns: the decimal value of the character in $a2 that is at the $a1 index
# in a string that is $a0 long.
# Called by: main
# Calls: none
    
determine_validity:
    add $t2, $zero, $zero               # Initialize index to 0.

  is_valid:
     
    lb $t1, 0($t0)                      # Load byte at $t0.
     
    # Check if the byte is valid
    bge $t1, 102, invalid_NaN           # If char larger than 102, it is invalid.
    bge $t1, 96, increment_char         # If char larger than 96, it is valid, lowercase.
    bge $t1, 70, invalid_NaN            # If char larger than 70, it is invalid.
    bge $t1, 64, increment_char         # If char larger than 64, it is valid, uppercase.
    bge $t1, 57, invalid_NaN            # If char larger than 57, it is invalid.
    bge $t1, 47, increment_char         # If char larger than 47, it is valid, number.
    j invalid_NaN

  increment_char:
    addi $t0, $t0, 1                    # Increment current pointer.
    addi $t2, $t2, 1                    # Increment index.
    bgt $t0, $a1, valid                 # If current pointer is past the end, the string is a valid hex.
    j is_valid
     
  invalid_NaN:
    addi $v0, $zero, 1                  # Set validity to 1.
    addi $v1, $zero, 0                  # Set length to 0.
    jr $ra
     
  invalid_too_long:
    addi $v0, $zero, 2                  # Set validity to 2.
    addi $v1, $zero, 0                  # Set length to 0, for it is not needed.
    jr $ra
  
  valid:
    bgt $t2, 7, invalid_too_long        # If length is greater than 8 then, it is a valid hex but too long.
    addi $v0, $zero, 3                  # Set validity to 1.
    add $v1, $zero, $t2                 # Set length to $t2.
    jr $ra
     
return:
    jr $ra  



   
    
########################################
# subprogram_1
# Converts a single hexadecimal character to a decimal integer.
#
# Assumptions:
# The character passed to the function is a valid hexadecimal character.
#
# Arg registers used: 
# $a0 - Length of hex.
# $a1 - Index of character.
# $a2 - ASCII character.
#
# Tmp registers used:
# $t0 - hex value
# $t1 - Exponent.
# $t3 - Decimal value of base, 16. 
# Return registers used:
# $v0 - Decimal value of the hexadecimal character.
#
# Pre: none
# Post: $v0 contains the return value.
# Returns: the decimal value of the character in $a2 that is at the $a1 index
# in a string that is $a0 long.
# Called by: subprogram_2
# Calls: none

subprogram_1:
    addi $v0, $zero, 1                  # Initialize $v0 to 1.
    addi $t3, $zero, 16                 # Initialize $t3 to 16.

  ascii_to_hex:
    bge $a2, 96, lower                  # If the character is upper case, branch to upper.
    bge $a2, 64, upper                  # If the character is lower case, branch to lower.
    bge $a2, 47, number                 # If the character is a number, branch to number.

  lower:
    addi $t0, $a2, -87                  # Store the decimal value of the hex character in $t0.
    j calculate_exponent

  upper:
    addi $t0, $a2, -55                  # Store the decimal value of the hex character in $t0.
    j calculate_exponent

  number:
    addi $t0, $a2, -48                  # Store the decimal value of the hex character in $t0.
    j calculate_exponent

  calculate_exponent:
    # Exponent = length - index - 1
    sub $t1, $a0, $a1                   # Exponent = length - index
    addi $t1, $t1, -1                   # Exponent = exponent - 1

  raise_base_to_exponent:
    beq $t1, $zero, multiply            # If exponent is zero, move on.

    mult $v0, $t3                       # Multiply exponent by base.
    mflo $v0                            # Store answer in $v0.

    addi $t1, $t1, -1                   # Decrement exponent.
    j raise_base_to_exponent

  multiply:
    mult $v0, $t0                       # Multiply base rased to exponent by the decimal value of the hex character.
    mflo $v0                            # Store result in $v0.

    jr $ra                    




########################################
# subprogram_2
# Converts a single hexadecimal string to a decimal integer.
#
# Loops through each character, calculates the decimal value for the hex character,
# adds the value to the sum. Returns the decimal value for the hex string.
#
# Arg registers used: 
# $a0 - Pointer to the start of the string.
# $a1 - Pointer to the end of the string.
# $a2 - Length of the string
# $a3 - Validity of string.
#
# Tmp registers used:
# $t0 - Pointer to the start of the string.
# $t1 - Pointer to the end of the string.
# $t2 - Length of the string.
# $t4 - Pointer to current position.
# $t9 - Decimal value ot current character.
# $s6 - Index of current character.
#
# Pre: none
# Post: $sp contains the return value.
# Returns: the decimal value of the hexadecimal string that starts at $a0 and 
# ends at $a1.
# Called by: main
# Calls: subprogram_1

subprogram_2:
    bne $a3, 3, return                  # If not a valid 8 char or less hex then return
    add $t0, $zero, $a0                 # Copy pointer to the start of the string.
    add $t1, $zero, $a1                 # Copy pointer to the end of the string.
    add $t2, $zero, $a2                 # Copy length of string.
    add $s6, $zero, $zero               # Initialize index to 0.
    add $t4, $zero, $t0                 # Pointer to the current position.
    add $t9, $zero, $zero               # Initialize decimal value of current character.

    
    # This function calls another function. Preserve the return address.
    add $s5, $zero, $ra                 # Save current $ra
     
  convert_hex_loop:     
    # For each character run the convert char
    # Set arguements for subprogram_1
    add $a0, $zero, $t2                 # Store length in $a0.
    add $a1, $zero, $s6                 # Store index in $a1.
    lb $a2, 0($t4)                      # Load character in $a2.

    jal subprogram_1                    # Call subprogram_1.
    
    add $t9, $t9, $v0                   # Store return value from subprogram_1.

    
    addi $t4, $t4, 1                    # Increment index.
    addi $s6, $s6, 1                    # Move current pointer to next position.
    
    blt $s6, $t2, convert_hex_loop      # If index < length then loop.
  
  done:
    addi $sp, $sp, -4                   # Allocate 4 bytes space on the stack.
    sw $t9, 0($sp)                      # Push the sum onto the stack.

    add $ra, $zero, $s5                 # Reset return address.
    jr $ra



########################################
# subprogram_3
# Displays a decimal value or error message.
#
# If $a0 is 1, prints 'NaN', if $a0 is 2, prints 'Too long', if $a0 is 3,
# prints the decimal on the stack $sp.
#
# Arg registers used: 
# $a0 - Validitiy of current string.
# $sp - Decimal value of the string.
#
# Tmp registers used:
# $t0 - Store the decimal 10000.
# $t1 - Decimal value of the hex.
# $t2 - Quotient.
# $t3 - Remainder.
#
# Pre: none
# Post: none
# Returns: none
# Called by: main
# Calls: none


subprogram_3:           
    beq $a0, 1, print_NaN               # If validitiy is 1, print 'NaN'.
    beq $a0, 2, print_too_long          # If validitiy is 2, print 'Too long'.
    beq $a0, 3, print_decimal           # If validitiy is 3, print the decimal.
    jr $ra

  print_NaN:
    la $a0, error_NaN                   # Print 'NaN'.                              
    li $v0, 4                                                                        
    syscall
    jr $ra

  print_too_long:
    la $a0, error_too_long              # Print 'Too long'.
    li $v0, 4
    syscall
    jr $ra

  print_decimal:
    la $a0, new_line                    # Print a new line.
    li $v0, 4                                                                                            
    syscall

    # Split the hex in two halves by dividing the unsigned integer by 10000. 
    # Solves the problem of the twos complement interpretation of the numbers.

    addi $t0, $zero, 10000      
    lw $t1, 0($sp)                      # Load the decimal from the stack.  
    addi $sp, $sp, 4                    # Deallocate the space on the stack.                    
     
    divu $t1, $t0                       # Divide decimal by 10000.   
    mflo $t2                            # Store the quotient.
    mfhi $t3                            # Store the remainder.
    
    beq $t2, $zero, print_remainder     # If quotient is 0, only print the remainder.
    
  print_quotient:
    add $a0, $zero, $t2                 # Print quotient                                          
    li $v0, 1                                                                                            
    syscall

  print_remainder:
    add $a0, $zero, $t3                 # Print remainder.                                              
    li $v0, 1                                                                 
    syscall

    jr $ra


