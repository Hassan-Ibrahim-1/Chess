class_name Move

extends Node

var start_square: Square
var target_square: Square
var piece: Piece
var side_color: int # Add to _init later
var en_passant_square: Square

func _init(s_square: Square, t_square: Square, p: Piece, s_en_passant: Square=null):
	start_square = s_square
	target_square = t_square
	piece = p
	en_passant_square = s_en_passant
