extends Node

enum PIECE_COLOR {
	WHITE = 0,
	BLACK = 1
}

enum PIECE_TYPES {
	PAWN,
	BISHOP,
	KNIGHT,
	ROOK,
	QUEEN,
	KING,
}

var square_scene = preload("res://scenes/square.tscn")
var piece_scene = preload("res://scenes/piece.tscn")

var square_arr: Array[Square]

# An array containing arrays of number of squares to edge
# First array has 64 elements each representing a square on the board
# Each element is an array that contains 8 elements
# Each of those 8 elements is an int that represents how many squares till the edge of the board
# Each element represents a different direction
var num_squares_to_edge: Array[Array]

# An array of offsets that is used to figure out how many squares away a direction is
# ie - how many squares need to be added to reach the northeastern square (immediate top right)
# directions share the same indices as the direction of the num_squares_to_edge array
var direction_offsets: Array[int] = [-8, 8, -1, 1, -9, 9, 7, -7]

# Set to the opposite color every move - default is white
var color_to_move: int = PIECE_COLOR.WHITE

func _ready():
	EventBus.connect("piece_moved", _on_piece_move)
	
	precompute_move_data()

func move_piece(piece: Piece, move: Move):
	move.start_square.remove_piece()
	move.target_square.add_piece(piece)

func create_board():
	## Sets up a full board with the opening position
	
	setup_empty_squares()
	var opening_fen: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
	var test_fen: String = "4kb1r/p4ppp/4q3/8/8/1B6/PPP2PPP/2KR4 w ---- 32 20"
	
	FENUtils.init(square_arr)
	FENUtils.load_fen(test_fen)
	#FENUtils.load_fen(opening_fen)

func setup_empty_squares():
	## Sets up a board with no pieces
	clear_board()
	# Loops 64 times and creates 64 squares
	# Sets alternate color if it needs to
	var colorbit = 0
	for x in range(8):
		for i in range(8):
			create_square()
			if i%2 == colorbit:
				square_arr[x*8+i].set_alternate_color()
		if colorbit == 0:
			colorbit = 1
		else:
			colorbit = 0

func get_square_arr() -> Array[Square]:
	return square_arr
	
func precompute_move_data():
	## Generates the number of squares to the edge of the board for each square
	
	# Vertical component of the board
	for rank in range(8):
		# Horizontal component of the board
		for file in range(8):
			
			var num_north: int = rank # Number of squares till the north edge of the board
			var num_south: int = 7 - rank # Number of squares till the south edge of the board
			var num_west: int = file # Number of squares till the west edge of the board
			var num_east: int = 7 - file # Number of squares till the east edge of the board
			
			# indices should be the same as square id
			num_squares_to_edge.append([
				num_north,
				num_south,
				num_west,
				num_east,
				min(num_north, num_west), # Northwest
				min(num_south, num_east), # Southeast
				min(num_south, num_west), # Southwest
				min(num_north, num_east), # Northeast
			])
			
			if rank*8 + file == 58:
				pass

func generate_moves() -> Array[Move]:
	var legal_moves: Array[Move] = []
	
	# Loops over all squares
	for square in square_arr:
		if square.piece_on_square == null:
			continue
	
		var piece: Piece = square.piece_on_square
		
		if piece.piece_color == color_to_move:
			
			if piece.is_sliding_piece():
				generate_sliding_moves(square, piece, legal_moves)
			elif piece.piece_type == PIECE_TYPES.PAWN:
				generate_pawn_moves(square, piece, legal_moves)
	
	return legal_moves
	
func generate_sliding_moves(start_square: Square, piece: Piece, legal_moves: Array[Move]):
	
	# These two variables are used to determine the direction that a sliding piece can go
	# ie - rooks can only move horizontally and bishops can only move diagonally
	# Used to determine where to start reading num_squares_to_edge
	var start_index: int = 0
	var end_index: int = 8
	
	# Diagonal directions only
	if piece.piece_type == PIECE_TYPES.BISHOP:
		start_index = 4
		
	# Horizontal and vertical direction only
	elif piece.piece_type == PIECE_TYPES.ROOK:
		end_index = 4
		
	for direction_index in range(start_index, end_index):
			# n is how many squares till the edge of the board in a given direction
		for n in range(num_squares_to_edge[start_square.ID][direction_index]):
			
			var target_square_id: int = start_square.ID + (direction_offsets[direction_index]) * (n + 1)
			
			var piece_on_target_square = square_arr[target_square_id].piece_on_square
			
			# Blocked by a friendly piece - can't move any further in this direction
			if piece_on_target_square != null:
				if piece_on_target_square.piece_color == piece.piece_color:
					break
			
			legal_moves.append(Move.new(start_square, square_arr[target_square_id]))
			
			# Blocked by an enemy piece - a capture is possible but can't move any further
			if piece_on_target_square != null:
				if piece_on_target_square.piece_color != piece.piece_color:
					break
			
	return legal_moves
	
func generate_pawn_moves(start_square: Square, piece: Piece, legal_moves: Array[Move]):
	
	if piece.piece_type != PIECE_TYPES.PAWN:
		return
	
	var direction_index: int
	
	# Determines the direction in which the pawn can go
	if piece.piece_color == PIECE_COLOR.WHITE:
		# North
		direction_index = 0
	else:
		# South
		direction_index = 1
	
	# How many squares forward the pawn can move 
	var squares_to_move: int = 1
	
	# If there is only one square in front of the pawn then set promoting to true
	if num_squares_to_edge[start_square.ID][direction_index] == 1:
		piece.promoting = true
	
	# Enables 2 move pawn pushes if the pawn is on the starting square
	if is_on_starting_square(piece, start_square.ID):
		squares_to_move = 2
	
	for n in range(squares_to_move):
		
		var target_square_id: int = start_square.ID + (direction_offsets[direction_index]) * (n + 1)
		
		var piece_on_target_square: Piece = square_arr[target_square_id].piece_on_square
		
		# Blocked by any piece - the pawn can't move forward
		if piece_on_target_square != null:
				break
		
		legal_moves.append(Move.new(start_square, square_arr[target_square_id]))

	
func create_square():
	var new_square: Square = square_scene.instantiate()
	new_square.ID = square_arr.size()
	square_arr.append(new_square)

func clear_board():
	square_arr = []

## This function is only used for pawns
## To determine if it should move two squares or just one
func is_on_starting_square(piece: Piece, piece_square_id: int) -> bool:
	
	# Contains IDs of starting squares for white and black
	var white_starting_squares: Array = range(48, 56)
	var black_starting_squares: Array = range(8, 16)
	
	if piece.piece_color == PIECE_COLOR.WHITE:
		
		if piece_square_id in white_starting_squares:
			return true
			
	else:
		if piece_square_id in black_starting_squares:
			return true
			
	return false

func _on_piece_move(target_square: Square):
	# Determines what color's turn it is
	if target_square.piece_on_square.piece_color == PIECE_COLOR.WHITE:
		color_to_move = PIECE_COLOR.BLACK
	else:
		color_to_move = PIECE_COLOR.WHITE
		
