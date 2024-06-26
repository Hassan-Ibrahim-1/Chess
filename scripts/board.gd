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

enum DIRECTION {
	NORTH,
	SOUTH,
	WEST,
	EAST,
	NORTHWEST,
	SOUTHEAST,
	SOUTHWEST,
	NORTHEAST
}

var square_scene = preload ("res://scenes/square.tscn")
var piece_scene = preload ("res://scenes/piece.tscn")

var square_arr: Array[Square]
var moves_played: Array[Move]

# An array containing arrays of number of squares to edge
# First array has 64 elements each representing a square on the board
# Each element is an array that contains 8 elements
# Each of those 8 elements is an int that represents how many squares till the edge of the board
# Each element represents a different direction
var num_squares_to_edge: Array[Array]

# An array of offsets that is used to figure out how many squares away a direction is
# ie - how many squares need to be added to reach the northeastern square (immediate top right)
# directions share the same indices as the direction of the num_squares_to_edge array
var direction_offsets: Array[int] = [- 8, 8, - 1, 1, - 9, 9, 7, - 7]

# Set to the opposite color every move - default is white
var color_to_move: int = PIECE_COLOR.WHITE

# Square that the promoting pawn is moving to
var promotion_square: Square
var promotion_piece: Piece

func _ready():
	EventBus.connect("piece_moved", _on_piece_move)
	
	precompute_move_data()

func move_piece(move: Move):
	# acts as a buffer for the piece that is moving
	var piece: Piece = move.start_square.piece
	
	move.start_square.remove_piece()

	# Removes any piece that may be on the target square
	# Thereby capturing that piece
	move.target_square.remove_piece()
	move.target_square.add_piece(piece)

	if move.en_passant_square != null:
		if is_diagonally_adjacent(move.start_square, move.target_square):
			move.en_passant_square.remove_piece()

func create_board():
	## Sets up a full board with the opening position
	
	setup_empty_squares()
	var opening_fen: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
	#var test_fen: String = "rnbq1bnr/ppppPp1p/5kp1/8/8/8/PPP1PPPP/RNBQKBNR w KQ - 0 5"
	
	FENUtils.init(square_arr)
	#FENUtils.load_fen(test_fen)
	FENUtils.load_fen(opening_fen)

func setup_empty_squares():
	## Sets up a board with no pieces
	clear_board()
	# Loops 64 times and creates 64 squares
	# Sets alternate color if it needs to
	var colorbit = 0
	for x in range(8):
		for i in range(8):
			create_square()
			if i % 2 == colorbit:
				square_arr[x * 8 + i].set_alternate_color()
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
			
func generate_moves() -> Array[Move]:
	var legal_moves: Array[Move] = []
	
	# Loops over all squares
	for square in square_arr:
		if square.piece == null:
			continue
	
		var piece: Piece = square.piece
		
		if piece.piece_color == color_to_move:
			
			if piece.is_sliding_piece():
				generate_sliding_moves(square, piece, legal_moves)
			elif piece.piece_type == PIECE_TYPES.PAWN:
				generate_pawn_moves(square, piece, legal_moves)
			elif piece.piece_type == PIECE_TYPES.KNIGHT:
				generate_knight_moves(square, piece, legal_moves)
	
	return legal_moves
	
func generate_sliding_moves(start_square: Square, piece: Piece, legal_moves: Array[Move]):
	
	# These two variables are used to determine the direction that a sliding piece can go
	# ie - rooks can only move horizontally and bishops can only move diagonally
	# Used to determine where to start reading num_squares_to_edge
	# Default values are for Queen - can move in all directions
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
			
			var piece_on_target_square = square_arr[target_square_id].piece
			
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
	
	var direction_index: int
	var adjacent_direction_indices: Array[int]
	var horizontal_direction_indices := [2, 3]
	
	# Determines the direction in which the pawn can go
	if piece.piece_color == PIECE_COLOR.WHITE:
		# North
		direction_index = 0
		
		# Northeast and Northwest
		adjacent_direction_indices = [4, 7]
	else:
		# South
		direction_index = 1
		
		# Southeast and Southwest
		adjacent_direction_indices = [6, 5]
	
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
		
		var piece_on_target_square: Piece = square_arr[target_square_id].piece
		
		# Blocked by any piece - the pawn can't move forward
		if piece_on_target_square != null:
				break
		
		legal_moves.append(Move.new(start_square, square_arr[target_square_id]))
		
	# Checking for adjacent square captures
	for adjacent_direction_index in adjacent_direction_indices:
		
		var target_square_id: int = start_square.ID + direction_offsets[adjacent_direction_index]
		
		var piece_on_target_square: Piece = square_arr[target_square_id].piece
		
		# If there is a piece on an adjacent square
		# If that piece is an any piece than a capture is possible
		if piece_on_target_square != null:
			if piece.piece_color != piece_on_target_square.piece_color:
				legal_moves.append(Move.new(start_square, square_arr[target_square_id]))
	
	# Checking for en passant
	for horizontal_direction_index in horizontal_direction_indices:
		
		# Game just started so no moves have been played
		if moves_played.size() == 0:
			break
		
		# Square ID of the piece next to the pawn
		var horizontal_square_id: int = start_square.ID + direction_offsets[horizontal_direction_index]
		
		var prev_move: Move = moves_played[- 1]
		
		if prev_move.target_square.ID == horizontal_square_id:
			
			# Target square is used because that piece has already moved
			if prev_move.target_square.piece.piece_type != PIECE_TYPES.PAWN:
				continue
			
			# If the piece has not moved two squares then move on to the next iteration
			if absi(prev_move.start_square.ID - prev_move.target_square.ID) != 16:
				continue
				
			var adjacent_direction_index: int
				
			# Pawn just moved to the left
			if horizontal_direction_index == 2:
				adjacent_direction_index = adjacent_direction_indices[0]
			
			# Pawn just moved to the right
			else:
				adjacent_direction_index = adjacent_direction_indices[1]
			
			var target_square_id: int = start_square.ID + direction_offsets[adjacent_direction_index]

			legal_moves.append(Move.new(start_square, square_arr[target_square_id], square_arr[horizontal_square_id]))
			
func generate_knight_moves(start_square: Square, piece: Piece, legal_moves: Array[Move]):
	# An array of squares that the knight can possibly move to
	var target_squares: Array[Square] = []

	# The ID of the square that is squares away from the starting square
	# Either horizontally or vertically
	var square_id: int

	# If the knight can move upwards
	if num_squares_to_edge[start_square.ID][DIRECTION.NORTH] > 1:
		square_id = start_square.ID + (direction_offsets[DIRECTION.NORTH] * 2)

		# If the knight can move to the left of the upper square
		if num_squares_to_edge[square_id][DIRECTION.WEST] != 0:
			target_squares.append(square_arr[square_id + direction_offsets[DIRECTION.WEST]])

		# If the knight can move to the right of the upper square
		if num_squares_to_edge[square_id][DIRECTION.EAST] != 0:
			target_squares.append(square_arr[square_id + direction_offsets[DIRECTION.EAST]])

	# If the knight can move downwards
	if num_squares_to_edge[start_square.ID][DIRECTION.SOUTH] > 1:
		square_id = start_square.ID + (direction_offsets[DIRECTION.SOUTH] * 2)

		# If the knight can move to the left of the lower square
		if num_squares_to_edge[square_id][DIRECTION.WEST] != 0:
			target_squares.append(square_arr[square_id + direction_offsets[DIRECTION.WEST]])

		# If the knight can move to the right of the lower square
		if num_squares_to_edge[square_id][DIRECTION.EAST] != 0:
			target_squares.append(square_arr[square_id + direction_offsets[DIRECTION.EAST]])

	# If the knight can move to the right
	if num_squares_to_edge[start_square.ID][DIRECTION.EAST] > 1:
		square_id = start_square.ID + (direction_offsets[DIRECTION.EAST] * 2)

		# If the knight can move to the top of the rightwards square
		if num_squares_to_edge[square_id][DIRECTION.NORTH] != 0:
			target_squares.append(square_arr[square_id + direction_offsets[DIRECTION.NORTH]])

		# If the knight can move to the bottom of the rightwards square
		if num_squares_to_edge[square_id][DIRECTION.SOUTH] != 0:
			target_squares.append(square_arr[square_id + direction_offsets[DIRECTION.SOUTH]])
	
	# If the knight can move to the left
	if num_squares_to_edge[start_square.ID][DIRECTION.WEST] > 1:
		square_id = start_square.ID + (direction_offsets[DIRECTION.WEST] * 2)

		# If the knight can move to the top of the leftwards square
		if num_squares_to_edge[square_id][DIRECTION.NORTH] != 0:
			target_squares.append(square_arr[square_id + direction_offsets[DIRECTION.NORTH]])

		# If the knight can move to the bottom of the leftwards square
		if num_squares_to_edge[square_id][DIRECTION.SOUTH] != 0:
			target_squares.append(square_arr[square_id + direction_offsets[DIRECTION.SOUTH]])

	for target_square in target_squares:
		if target_square.piece != null:
			# If its a friendly piece then continue
			if target_square.piece.piece_color == piece.piece_color:
				continue

		legal_moves.append(Move.new(start_square, target_square))

func create_square():
	var new_square: Square = square_scene.instantiate()
	new_square.ID = square_arr.size()
	square_arr.append(new_square)

func clear_board():
	square_arr = []

## Checks if a square is diagonally adjacent to another square 
func is_diagonally_adjacent(square1: Square, square2: Square) -> bool:
	var adjacent_direction_indices := [4, 5, 6, 7]
	for index in adjacent_direction_indices:
		if (square1.ID + direction_offsets[index]) == square2.ID:
			return true
	return false

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
	if target_square.piece.piece_color == PIECE_COLOR.WHITE:
		color_to_move = PIECE_COLOR.BLACK
	else:
		color_to_move = PIECE_COLOR.WHITE
