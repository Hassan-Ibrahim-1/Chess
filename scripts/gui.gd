class_name GUI

extends Control

#@onready var square_scene = preload("res://scenes/square.tscn")
#@onready var piece_scene = preload("res://scenes/piece.tscn")
@onready var grid_container = $Background/GridContainer

var arrows: Array[Arrow]

var arrow_scene = preload("res://scenes/arrow.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	#var square_arr: Array[Square] = Board.create_board()
	var square_arr: Array[Square] = Board.get_square_arr()
	for square in square_arr:
		grid_container.add_child(square)

func draw_arrow(start_pos: Vector2, end_pos: Vector2):
	#
	#print_debug("Start position: %s" % start_pos)
	#print_debug("End position: %s" % start_pos)
	
	var arrow = arrow_scene.instantiate()
	arrows.append(arrow)
	add_child(arrow)

	arrow.init(start_pos, end_pos)
	
func clear_arrows():
	for arrow in arrows:
		arrow.queue_free()
	arrows = []
