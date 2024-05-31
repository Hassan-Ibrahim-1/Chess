class_name Move

extends Node

var start_square: Square
var target_square: Square
var piece_type: int
var side_color: int # Add to _init later

func _init(st_square: Square, targ_square: Square, p_type: int):
	start_square = st_square
	target_square = targ_square
	piece_type = p_type
