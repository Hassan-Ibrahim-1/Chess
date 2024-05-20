extends Node

enum PIECE_COLOR {
	WHITE = 0,
	BLACK = 1,
}

enum PIECE_TYPES {
	PAWN,
	BISHOP,
	KNIGHT,
	ROOK,
	QUEEN,
	KING,
}

enum FEN_INDEX {
	PIECE_PLACEMENT,
	SIDE_TO_MOVE,
	CASTLING_ABILITY,
	EN_PASSANT,
	HALFMOVE_CLOCK,
	FULLMOVE_COUNTER,
}

@onready var piece_scene = preload("res://scenes/piece.tscn")

var square_arr: Array[Square]

func init(square_array: Array[Square]):
	square_arr = square_array

# Gets the information out of a FEN string
# Sets up the pieces on the board
# Returns information extracted from the FEN string - side to move, etc
func load_fen(fenstr: String) -> Array:
	#TODO: Add a check to make sure the FEN string is valid
	
	# Array to be returned
	# Contains all information about the game extracted from the FEN string - side to move, etc
	var fen_info: Array = []
	
	# Split the different sections of the FEN string
	var fenstr_arr := fenstr.split(" ")
	
	# Splits the piece placement section of the FEN string into an array
	# This array represents ranks of the chessboard
	var placement_arr = fenstr_arr[FEN_INDEX.PIECE_PLACEMENT].split("/")
	
	# Used to index through square_arr
	var index: int = 0
	var piece_color: int
	
	# Loop through placement_arr
	# skip squares if chr is a number
	# else add a piece based on chr
	for rank in placement_arr:
		# chr represents each character in a rank
		
		for chr in rank:
			
			# Skips the rank if chr is 8
			if chr == "8":
				index += 8
				continue
				
			# Skips int(chr) amount of squares when chr is a number
			if chr.is_valid_int():
				index += int(chr)
			# If chr is a letter then try and find what piece the letter represents
			else:
				
				# Black if the character is lower case
				# white if the character is upper case
				if chr == chr.to_lower():
					piece_color = PIECE_COLOR.BLACK
				else:
					piece_color = PIECE_COLOR.WHITE
					
				match chr.to_lower():
					"p":
						add_piece(PIECE_TYPES.PAWN, piece_color, square_arr[index])
					"b":
						add_piece(PIECE_TYPES.BISHOP, piece_color, square_arr[index])
					"n":
						add_piece(PIECE_TYPES.KNIGHT, piece_color, square_arr[index])
					"r":
						add_piece(PIECE_TYPES.ROOK, piece_color, square_arr[index])
					"q":
						add_piece(PIECE_TYPES.QUEEN, piece_color, square_arr[index])
					"k":
						add_piece(PIECE_TYPES.KING, piece_color, square_arr[index])
					_:
						print_debug("INVALID FEN STRING!")
				index += 1
				
	# Side to move
#	fen_info.append(fenstr_arr[FEN_INDEX.SIDE_TO_MOVE])
	
	# Half move clock - counter that resets every capture or pawn move - game draws when this reaches 50
	# increments every move
#	fen_info.append(fenstr_arr[FEN_INDEX.HALFMOVE_CLOCK])
	
	# Full move counter - number of full moves in the game - incremented after every Black move 
#	fen_info.append(fenstr_arr[FEN_INDEX.FULLMOVE_COUNTER])
	
	# TODO: Represent castling ability and En passant target square
	
	return fen_info

func add_piece(piece_type: int, piece_color: int, square: Square):
	var piece = piece_scene.instantiate()
	piece.init(piece_type, piece_color)
	square.add_piece(piece)
