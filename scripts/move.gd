extends Node

class_name Move

var start_square: Square
var target_square: Square
var side_color: int # Add to _init later

func _init(st_square: Square, targ_square: Square):
	start_square = st_square
	target_square = targ_square
