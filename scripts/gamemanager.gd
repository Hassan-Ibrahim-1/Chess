class_name GameManager
extends Node

var click_count: int = 0
var prev_square_clicked: Square = null # Holds previous clicked square

@onready var gui = %GUI
var highlighted_squares: Array[Square]

var arrow_start_pos: Vector2



func _ready():
	EventBus.connect("click", _on_square_click)
	EventBus.connect("release", _on_square_release)
	EventBus.connect("right_click", _on_square_right_click)
	EventBus.connect("right_click_release", _on_square_right_click_release)
	EventBus.connect("promotion_piece_chosen", _on_promotion_piece_chosen)

	Board.create_board()

func _on_square_click(square: Square):
	gui.clear_arrows()
	gui.clear_highlighted_squares()

	if gui.promotion_menu_enabled:
		# Get the square above the prev_square_clicked and the two squares below it
		# Include the square itself as well
		# if is_in_promotion_menu(prev_square_clicked.piece)
		# TODO: Only execute this code when a square that is clicked is not the square that the promotion menu is on
		gui.delete_promotion_menu()

		# Shows the piece that was hidden previously in _on_square_release
		# prev_square_clicked is being used because it hasn't been updated to the promotion_square
		if Board.promotion_piece != null:
			Board.promotion_piece.show()
		if Board.promotion_square.piece != null:
			Board.promotion_square.piece.show()

		return

	print_debug(square.ID)
	if (square.piece != null) and (click_count == 0):
		click_count = 1
		
	elif click_count == 1:
		click_count = 2
		
	if click_count == 2:
		# On two clicks check if the previous square had a piece on it
		# If it did then move that piece to the square that has just been clicked
		# Unless the start and target squares are the same
		# Set signal_count to 0 to restart the check for squares
		
		click_count = 0
		
		if (prev_square_clicked.piece != null) and (prev_square_clicked != square):
			
			# TODO: get rid of this conditional after all legal moves have been implemented
			if prev_square_clicked.piece.piece_type != Board.PIECE_TYPES.KING:
				process_move(square)
			else:
				var move: Move = Move.new(prev_square_clicked, square)
				make_move(move)
			
	# On new click set previous square color to default
	if prev_square_clicked != null and prev_square_clicked != square:
		prev_square_clicked.set_default_color()
		
	prev_square_clicked = square

func _on_square_release(square: Square):
	# If the square the mouse is released is not the previusly clicked square
	# Then move the piece to the square that the mouse was released on
	# Click count is set to 0 because the first click sets it to 1 and the mouse release does not count as a click
	# Even though the piece moved click count is still 1 - this causes bugs - piece not behaving right after dragging
	if (prev_square_clicked.piece != null) and (prev_square_clicked != square):
		click_count = 0
		
		# TODO: get rid of this conditional after all legal moves have been implemented
		if prev_square_clicked.piece.piece_type != Board.PIECE_TYPES.KING:
			process_move(square)

		else:
			var move: Move = Move.new(prev_square_clicked, square)
			make_move(move)
		
		# if is_move_legal(square, legal_moves):
			# make_move()
			
# Records the square that is right clicked on
# This square is where the arrow starts
func _on_square_right_click(mouse_pos: Vector2):
	
		arrow_start_pos = mouse_pos

# Records the target square of the arrow
# The target square is the square that the RMB is released on
# Calls gui.draw_arrow() which draws the arrow
func _on_square_right_click_release(mouse_pos: Vector2, square: Square):

	# If the promotion menu is enabled, delete it and stop execution of the function
	if gui.promotion_menu_enabled:
		gui.delete_promotion_menu()

		# Shows the piece that was hidden previously in _on_square_release
		prev_square_clicked.piece.show()

		return
	
	gui.draw_arrow(arrow_start_pos, mouse_pos)

	if square.is_highlighted:
		square.set_default_color()
	else:
		square.set_highlight_color()
		highlighted_squares.append(square)

## Checks if a move is legal
## If the move is legal then execute the move
## Also checks for promotions
func process_move(target_square: Square):
	var legal_moves = Board.generate_moves()
	var move: Move = is_move_legal(target_square, legal_moves)

	# If the false the move is illegal
	if move.target_square != null:
		
		# If a pawn is promoting
		if move.start_square.piece.promoting:
			
			gui.create_promotion_menu(target_square, move.start_square.piece.piece_color)
			
			Board.promotion_square = target_square
			Board.promotion_piece = move.start_square.piece

			# Removes piece from board until a signal is emitted
			Board.promotion_piece.hide()
			
			# Removes any piece that may be on the promotion square
			if Board.promotion_square.piece != null:
				Board.promotion_square.piece.hide()

		else:
			make_move(move)

func _on_promotion_piece_chosen(piece_type: int):
	if prev_square_clicked.piece != null:
		Board.promotion_piece.promote(piece_type)
		Board.promotion_piece.show()

	# Make move 
		gui.delete_promotion_menu()
		var move: Move = Move.new(prev_square_clicked, Board.promotion_square)
		make_move(move)

func make_move(move: Move):
	# Makes a move - uses the global prev_square_clicked as the start square
	# Highlights the target square and the original square
	# sets previous square clicked to the target square
	$AudioStreamPlayer2D.play()

	Board.move_piece(move)
	Board.moves_played.append(move)

	EventBus.piece_moved.emit(move.target_square)

	move.start_square.set_default_color()
	move.target_square.set_highlight_color()

## Returns the legal_move if the move is legal
## Return a move with all parameters set to null if not true
func is_move_legal(target_square: Square, legal_moves: Array[Move]) -> Move:
	var move: Move = Move.new(prev_square_clicked, target_square)
	for legal_move in legal_moves:
		# TODO: Change this to a function later
		if move.start_square.ID == legal_move.start_square.ID and move.target_square.ID == legal_move.target_square.ID:
			return legal_move

	return Move.new(null, null, null)
