class_name Move

extends Node

var start_square: Square
var target_square: Square
# The square that contains the piece horizontal to the pawn in en passant situations
var en_passant_square: Square

func _init(s_square: Square, t_square: Square, s_en_passant: Square=null):
	start_square = s_square
	target_square = t_square
	en_passant_square = s_en_passant
