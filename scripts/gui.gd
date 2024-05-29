class_name GUI

extends Control

#@onready var square_scene = preload("res://scenes/square.tscn")
#@onready var piece_scene = preload("res://scenes/piece.tscn")
@onready var grid_container = $Background/GridContainer
@onready var color_to_move_text = $Background/ColorToMoveText

var arrows: Array[Arrow]
var highlighted_squares: Array[Square]

var arrow_scene = preload("res://scenes/arrow.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	# Used to update side to move
	EventBus.connect("piece_moved", _on_piece_move)
	var square_arr: Array[Square] = Board.get_square_arr()
	for square in square_arr:
		grid_container.add_child(square)
		
	update_color_to_move_text()

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
	

func clear_highlighted_squares():
	for squares in highlighted_squares:
		squares.set_default_color()
	highlighted_squares = []

	

func _on_piece_move(_square):
	update_color_to_move_text()

func update_color_to_move_text():
	print ("hi")
	
	if Board.color_to_move == Board.PIECE_COLOR.WHITE:
		color_to_move_text.text = "Color to move: White"
	else:
		color_to_move_text.text = "Color to move: Black"
		
