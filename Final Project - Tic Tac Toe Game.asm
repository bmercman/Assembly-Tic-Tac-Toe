# Author - Benjamin Mercier
.data
board: .word 0,0,0,0,0,0,0,0,0 # stores value of game grid
prompt1: .asciiz "\nPlayer 1 choose X or O (Enter 1 or 2): " # mark selection prompt
prompt2: .asciiz "\nPlayer 1 is X and Player 2 is O\n"
prompt3: .asciiz "\nPlayer 1 is O and Player 2 is X\n"
empty: .asciiz "-"
space: .asciiz " | "
X: .asciiz "X"
O: .asciiz "O"
divider: .asciiz "\n------------\n"
player1: .asciiz "\nPlayer 1 select a space (1 - 9): "
player2: .asciiz "\nPlayer 2 select a space (1 - 9): "
player1win: .asciiz "\nPlayer 1 WINS!"
player2win: .asciiz "\nPlayer 2 WINS!"
draw: .asciiz "\nGame Draw!"
playagain: .asciiz "\nWould you like to play again? (select 1 for YES and 2 for NO):"
newline: .asciiz "\n"

.text

la $a0, board # load board array

main:
# prompt player to choose thier mark
la $a0, prompt1
li $v0, 4 
syscall

# read int and move to $s0
li $v0, 5 # read int
syscall
move $s0, $v0 # move player 1 choice to $s0

jal chooseMarks # calls function to check players choice

jal drawGrid # calls function to diplay grid

addi $t0,$zero,1

j playerMove # jump to player turn labels

playerMove:
	beq $t0,1, player1Action # checks if its player 1 turn
	
	beq $t0,2, player2Action # checks if its player 2 turn
	
player1Action:
	j player1Turn # calls function for player 1 to make their move
	
player2Action:
	j player2Turn # calls function for player 2 to make their move

# end program
exit:
	li $v0, 10
	syscall

chooseMarks:

	beq $s0, 2, displayChoice # checks if player 1 is X
	
	# display players choice if player 1 is x
	la $a0, prompt2
	li $v0, 4 
	syscall
	
	add $s1, $zero, 1 # $s1 holds player 1 mark
	add $s2, $zero, 2 # $s2 holds player 2 mark
	
	jr $ra
	
	displayChoice:
		# display players choice if player 1 is o
		la $a0, prompt3
		li $v0, 4
		syscall
		
		add $s1, $zero, 2 # $s1 holds player 1 mark
		add $s2, $zero, 1 # $s2 holds player 1 mark
		
		jr $ra

drawGrid:
	# prints text based grid
	la $a0, empty
	li $v0, 4 
	syscall
	la $a0, space
	li $v0, 4 
	syscall
	la $a0, empty
	li $v0, 4 
	syscall
	la $a0, space
	li $v0, 4 
	syscall
	la $a0, empty
	li $v0, 4 
	syscall
	la $a0, divider
	li $v0, 4 
	syscall
	la $a0, empty
	li $v0, 4 
	syscall
	la $a0, space
	li $v0, 4 
	syscall
	la $a0, empty
	li $v0, 4 
	syscall
	la $a0, space
	li $v0, 4 
	syscall
	la $a0, empty
	li $v0, 4 
	syscall
	la $a0, divider
	li $v0, 4 
	syscall
	la $a0, empty
	li $v0, 4 
	syscall
	la $a0, space
	li $v0, 4 
	syscall
	la $a0, empty
	li $v0, 4 
	syscall
	la $a0, space
	li $v0, 4 
	syscall
	la $a0, empty
	li $v0, 4 
	syscall
	
	jr $ra
	
player1Turn:
	# prompt player 1 to place their mark
	la $a0, player1
	li $v0, 4 
	syscall
	# read int and move to $t1
	li $v0, 5 # read int
	syscall
	move $t1, $v0 # move player 1 choice into $t1, keeps track of players current move
	
	sub $t1,$t1,1 # subtract 1 from choice to keep inline with indexing
	
	# update player 1 move
	jal boardUpdatePlayer1
	
	addi $t0,$zero,2 # set it to player 2 turn next
	
	j drawUpdateBoard # draw updated grid
	
player2Turn:
	# prompt player 2 to place their mark
	la $a0, player2
	li $v0, 4 
	syscall
	# read int and move to $t2
	li $v0, 5 # read int
	syscall
	move $t2, $v0 # move player 2 choice into $t2, keeps track of players current move
	
	sub $t2,$t2,1 # subtract 1 from choice to keep inline with indexing
	
	# update player 2 move
	jal boardUpdatePlayer2
	
	addi $t0,$zero,1 # set it to player 1 turn next
	
	j drawUpdateBoard # draw updated grid
	
	
boardUpdatePlayer1:
	addi $t3, $zero, 0 # clears index
	mul $t1, $t1, 4 # multiplies players move by 4 to be appropriate for indexing
	add $t3, $zero, $t1 # sets index to the place player 1 wants to place their mark
	sw $s1, board($t3) # sets position in array to player 1 mark
	
	jr $ra
	
boardUpdatePlayer2:
	addi $t3, $zero, 0 # clears index
	mul $t2, $t2, 4 # multiplies players move by 4 to be appropriate for indexing
	add $t3, $zero, $t2 # sets index to the place player 2 wants to place their mark
	sw $s2, board($t3) # sets position in array to player 2 mark
	
	jr $ra	

drawUpdateBoard:	
	addi $t4, $zero, 0 # sets counter to 0
	checkArray:
		addi $t4, $t4, 1 # adds 1 to counter each time
		bgt $t4, 9, checkWin # exit loop when end of array reached, when counter = 9
		
		move $t5, $t4 # set $t5 to value of $t4
		sub $t5,$t5,1 # subtract 1 from counter to keep inline with indexing
		mul $t5, $t5, 4 # $t5 is the index used to search array
		lb $t6, board($t5) # gets value of array at $t5 index and loads it into $t6
		bgtz $t6, checkMark # if the value of the array is greater then zero, check to see if X or O
		beqz $t6, printEmpty # if the value of the array is 0, print a blank space
		# draw grid
		j checkMark
		
checkMark: 
	# check to see if the value in the array is a 1 for X or a 2 for O
	beq $t6, 1, printX # if value of array is a 1 go to X
	
	beq $t6, 2, printO # if the value of the array is a 2 go to O
	
printEmpty:
	la $a0, empty
	li $v0, 4 
	syscall 
	
	j printSpace
			
printX:
	la $a0, X
	li $v0, 4 
	syscall		
	
	j printSpace

printO:
	la $a0, O
	li $v0, 4 
	syscall		
	
	j printSpace
	
printSpace:
	beq $t4, 3, printDivider # if 3 spots have been checked in the array, jump to divider to start a new row
	
	beq $t4, 6, printDivider # if 6 spots have been checked in the array, jump to divider to start a new row
	
	beq $t4, 9, checkArray # once last space filled go to checkArray
	
	la $a0, space # print a space between marks
	li $v0, 4 
	syscall
	
	j checkArray
		
printDivider:
	la $a0, divider
	li $v0, 4 
	syscall	
	
	j checkArray
				
checkWin:

firstRow1:
	addi $t7, $zero, 0
	addi $t8, $zero, 0
	addi $t9, $zero, 0

	addi $t3, $zero, 0
	lb $t7,board($t3)
	addi $t3, $zero, 4
	lb $t8,board($t3)
	addi $t3, $zero, 8
	lb $t9,board($t3)
	
	beq $t7, 0, secondRow1
	beq $t8, 0, secondRow1
	beq $t9, 0, secondRow1
	
	j firstRow2 # check first row
	
secondRow1:	
	addi $t7, $zero, 0
	addi $t8, $zero, 0
	addi $t9, $zero, 0
	
	addi $t3, $zero, 12
	lb $t7,board($t3)
	addi $t3, $zero, 16
	lb $t8,board($t3)
	addi $t3, $zero, 20
	lb $t9,board($t3)
	
	beq $t7, 0, thirdRow1
	beq $t8, 0, thirdRow1
	beq $t9, 0, thirdRow1
	
	j secondRow2 # check second row

thirdRow1:		
	addi $t7, $zero, 0
	addi $t8, $zero, 0
	addi $t9, $zero, 0
	
	addi $t3, $zero, 24
	lb $t7,board($t3)
	addi $t3, $zero, 28
	lb $t8,board($t3)
	addi $t3, $zero, 32
	lb $t9,board($t3)
	
	beq $t7, 0, firstColumn1
	beq $t8, 0, firstColumn1
	beq $t9, 0, firstColumn1
	
	j thirdRow2 # check third row

firstColumn1:	
	addi $t7, $zero, 0
	addi $t8, $zero, 0
	addi $t9, $zero, 0
		
	addi $t3, $zero, 0
	lb $t7,board($t3)
	addi $t3, $zero, 12
	lb $t8,board($t3)
	addi $t3, $zero, 24
	lb $t9,board($t3)
	
	beq $t7, 0, secondColumn1
	beq $t8, 0, secondColumn1
	beq $t9, 0, secondColumn1

	j firstColumn2 # check first column

secondColumn1:	
	addi $t7, $zero, 0
	addi $t8, $zero, 0
	addi $t9, $zero, 0
		
	addi $t3, $zero, 4
	lb $t7,board($t3)
	addi $t3, $zero, 16
	lb $t8,board($t3)
	addi $t3, $zero, 28
	lb $t9,board($t3)
	
	beq $t7, 0, thirdColumn1
	beq $t8, 0, thirdColumn1
	beq $t9, 0, thirdColumn1

	j secondColumn2 # check second column

thirdColumn1:	
	addi $t7, $zero, 0
	addi $t8, $zero, 0
	addi $t9, $zero, 0
		
	addi $t3, $zero, 8
	lb $t7,board($t3)
	addi $t3, $zero, 20
	lb $t8,board($t3)
	addi $t3, $zero, 32
	lb $t9,board($t3)
	
	beq $t7, 0, firstDiagonal1
	beq $t8, 0, firstDiagonal1
	beq $t9, 0, firstDiagonal1

	j thirdColumn2 # check third column

firstDiagonal1:	
	addi $t7, $zero, 0
	addi $t8, $zero, 0
	addi $t9, $zero, 0
		
	addi $t3, $zero, 0
	lb $t7,board($t3)
	addi $t3, $zero, 16
	lb $t8,board($t3)
	addi $t3, $zero, 32
	lb $t9,board($t3)
	
	beq $t7, 0, secondDiagonal1
	beq $t8, 0, secondDiagonal1
	beq $t9, 0, secondDiagonal1

	j firstDiagonal2 # check first diagonal

secondDiagonal1:	
	addi $t7, $zero, 0
	addi $t8, $zero, 0
	addi $t9, $zero, 0
		
	addi $t3, $zero, 8
	lb $t7,board($t3)
	addi $t3, $zero, 16
	lb $t8,board($t3)
	addi $t3, $zero, 24
	lb $t9,board($t3)
	
	beq $t7, 0, checkDraw
	beq $t8, 0, checkDraw
	beq $t9, 0, checkDraw
	
	j secondDiagonal2 # check second diagonal
	
firstRow2:
	add $t3, $t7, $t8
	add $t3, $t3, $t9
	beq $t3, 3, winner # if row total is equal to 3, winner
	beq $t3, 6, winner # if row total is equal to 6, winner
	
	j secondRow1
			
secondRow2:
	add $t3, $t7, $t8
	add $t3, $t3, $t9
	beq $t3, 3, winner # if row total is equal to 3, winner
	beq $t3, 6, winner # if row total is equal to 6, winner
	
	j thirdRow1
	
thirdRow2:
	add $t3, $t7, $t8
	add $t3, $t3, $t9
	beq $t3, 3, winner # if row total is equal to 3, winner
	beq $t3, 6, winner # if row total is equal to 6, winner
	
	j firstColumn1
	
firstColumn2:
	add $t3, $t7, $t8
	add $t3, $t3, $t9
	beq $t3, 3, winner # if row total is equal to 3, winner
	beq $t3, 6, winner # if row total is equal to 6, winner
	
	j secondColumn2
	
secondColumn2:
	add $t3, $t7, $t8
	add $t3, $t3, $t9
	beq $t3, 3, winner # if row total is equal to 3, winner
	beq $t3, 6, winner # if row total is equal to 6, winner
	
	j thirdColumn1
	
thirdColumn2:
	add $t3, $t7, $t8
	add $t3, $t3, $t9
	beq $t3, 3, winner # if row total is equal to 3, winner
	beq $t3, 6, winner # if row total is equal to 6, winner
	
	j firstDiagonal1
	
firstDiagonal2:
	add $t3, $t7, $t8
	add $t3, $t3, $t9
	beq $t3, 3, winner # if row total is equal to 3, winner
	beq $t3, 6, winner # if row total is equal to 6, winner
	
	j secondDiagonal1
	
secondDiagonal2:
	add $t3, $t7, $t8
	add $t3, $t3, $t9
	beq $t3, 3, winner # if row total is equal to 3, winner
	beq $t3, 6, winner # if row total is equal to 6, winner
	
	j checkDraw
			
checkDraw:
	addi $t4, $zero, 0 # sets counter to 0
	checkArray2:
		addi $t4, $t4, 1 # adds 1 to counter each time
		bgt $t4, 9, printDraw # exit loop when end of array reached, when counter = 9
		
		move $t5, $t4 # set $t5 to value of $t4
		sub $t5,$t5,1 # subtract 1 from counter to keep inline with indexing
		mul $t5, $t5, 4 # $t5 is the index used to search array
		lb $t6, board($t5) # gets value of array at $t5 index and loads it into $t6
		beqz $t6, playerMove # if there is a space still available continue game
		j checkArray2		
		
printDraw:
	la $a0, draw
	li $v0, 4 
	syscall
	
	j playAgain
		
winner:
	beq $t0,2, p1Wins # if a win was detected during player 1's turn, player 1 wins
	beq $t0,1, p2Wins # if a win was detected during player 2's turn, player 2 wins
	
p1Wins:
	la $a0, player1win
	li $v0, 4 
	syscall
	
	j playAgain
	
p2Wins:
	la $a0, player2win
	li $v0, 4 
	syscall		
		
	j playAgain
	
playAgain:
	# ask player if they would like to play again
	la $a0, playagain
	li $v0, 4 
	syscall

	# read int and move to $s0
	li $v0, 5 # read int
	syscall
	move $s0, $v0 # move players choice to $s0
	
	beq $s0, 1, resetGame # players want to play again, array must be reset
	
	j exit # end program
	
resetGame:
	addi $t4, $zero, 0 # sets counter to 0
	addi $t6, $zero, 0 # sets $t6 to 0
	clearArray:
		addi $t4, $t4, 1 # adds 1 to counter each time
		bgt $t4, 9, main # exit loop when end of array reached, when counter = 9
		
		move $t5, $t4 # set $t5 to value of $t4
		sub $t5,$t5,1 # subtract 1 from counter to keep inline with indexing
		mul $t5, $t5, 4 # $t5 is the index used to search array
		sw $t6, board($t5) # sets position in array to zero
		j clearArray
	
		
			
				
					
							
