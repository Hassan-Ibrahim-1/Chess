extends Node

var square_arr: Array[Square]


var square_scene = preload("res://scenes/square.tscn")
var piece_scene = preload("res://scenes/piece.tscn")

func move_piece(piece: Piece, move: Move):
	move.start_square.remove_piece()
	move.target_square.add_piece(piece)

func create_board():
	setup_empty_squares()
	var opening_fen: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
	var test_fen: String = "4kb1r/p4ppp/4q3/8/8/1B6/PPP2PPP/2KR4 w ---- 32 20"
	
	FENUtils.init(square_arr)
	#FENUtils.load_fen(test_fen)
	FENUtils.load_fen(opening_fen)

func setup_empty_squares():
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

func get_square_arr():
	return square_arr

func create_square():
	var new_square: Square = square_scene.instantiate()
	new_square.ID = square_arr.size()
	square_arr.append(new_square)

func clear_board():
	square_arr = []
