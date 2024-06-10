extends Node
class_name GameManager

var click_count: int = 0
var prev_square_clicked: Square = null # Holds previous clicked square

@onready var gui = %GUI

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

	# If the promotion menu is enabled, delete it and stop execution of the function
	if gui.promotion_menu_enabled:
		gui.delete_promotion_menu()

		# Shows the piece that was hidden previously in _on_square_release
		prev_square_clicked.piece_on_square.show()

		return

	print_debug(square.ID)
	if (square.piece_on_square != null) and (click_count == 0):
		click_count = 1
		
	elif click_count == 1:
		click_count = 2
		
	if click_count == 2:
		# On two clicks check if the previous square had a piece on it
		# If it did then move that piece to the square that has just been clicked
		# Unless the start and target squares are the same
		# Set signal_count to 0 to restart the check for squares
		
		click_count = 0
		
		if (prev_square_clicked.piece_on_square != null) and (prev_square_clicked != square):
			# TODO: get rid of this conditional after all legal moves have been implemented
			if prev_square_clicked.piece_on_square.piece_type != Board.PIECE_TYPES.KING:
				var legal_moves = Board.generate_moves()
				if is_move_legal(square, legal_moves):
					# If a pawn is about to promote - make it a queen
					# TODO: change this later to include all promotion pieces
					if prev_square_clicked.piece_on_square.promoting:
						var piece_type: int
						gui.create_promotion_menu(square, prev_square_clicked.piece_on_square.piece_color)
						prev_square_clicked.piece_on_square.promote(piece_type)
					make_move(square)
			else:
				make_move(square)
			
	# On new click set previous square color to default
	if prev_square_clicked != null and prev_square_clicked != square:
		prev_square_clicked.set_default_color()
		
	prev_square_clicked = square

func _on_square_release(square: Square):
	# If the square the mouse is released is not the previusly clicked square
	# Then move the piece to the square that the mouse was released on
	# Click count is set to 0 because the first click sets it to 1 and the mouse release does not count as a click
	# Even though the piece moved click count is still 1 - this causes bugs - piece not behaving right after dragging
	if (prev_square_clicked.piece_on_square != null) and (prev_square_clicked != square):
		click_count = 0
		# TODO: get rid of this conditional after all legal moves have been implemented
		if prev_square_clicked.piece_on_square.piece_type != Board.PIECE_TYPES.KING:
			var legal_moves = Board.generate_moves()
			if is_move_legal(square, legal_moves):
				if prev_square_clicked.piece_on_square.promoting:
					# TODO: Change this later to include all possible promotion pieces
					# Promotes the pawn to a queen if it is moving to a promotion square
					var piece_type: int
					gui.create_promotion_menu(square, prev_square_clicked.piece_on_square.piece_color)
					
					# Removes piece from board until a signal is emitted
					prev_square_clicked.piece_on_square.hide()

					# prev_square_clicked.piece_on_square.promote(piece_type)

				else:
					make_move(square)
		else:
			make_move(square)
		
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
	gui.draw_arrow(arrow_start_pos, mouse_pos)
	
	if square.is_highlighted:
		square.set_default_color()
	else:
		square.set_highlight_color()

func _on_promotion_piece_chosen(piece_type: int):
	pass
		
func make_move(target_square: Square):
	# Makes a move - uses the global prev_square_clicked as the start square
	# Highlights the target square and the original square
	# sets previous square clicked to the target square
	$AudioStreamPlayer2D.play()
	
	var move: Move = Move.new(prev_square_clicked, target_square, prev_square_clicked.piece_on_square)
	Board.move_piece(prev_square_clicked.piece_on_square, move)
	Board.moves_played.append(move)
	
	EventBus.piece_moved.emit(target_square)
	
	prev_square_clicked.set_default_color()
	target_square.set_highlight_color()
	prev_square_clicked = target_square

func is_move_legal(target_square: Square, legal_moves: Array[Move]):
	var move: Move = Move.new(prev_square_clicked, target_square, prev_square_clicked.piece_on_square)
	for legal_move in legal_moves:
		# TODO: Change this to a function later
		if move.start_square.ID == legal_move.start_square.ID and move.target_square.ID == legal_move.target_square.ID:
			return true
			
	return false
