class_name Move

extends Node

var start_square: Square
var target_square: Square
var piece: Piece
var side_color: int # Add to _init later

func _init(s_square: Square, t_square: Square, p: Piece):
	start_square = s_square
	target_square = t_square
	piece = p
