class_name Move

extends Node

var start_square: Square
var target_square: Square
var piece: Piece
var side_color: int # Add to _init later
var en_passant_possible: bool

func _init(s_square: Square, t_square: Square, p: Piece, en_passant: bool=false):
	start_square = s_square
	target_square = t_square
	piece = p
	en_passant_possible = en_passant
