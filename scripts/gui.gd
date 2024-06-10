class_name GUI

extends Control

var promotion_menu_scene: PackedScene = preload ("res://scenes/promotion_menu.tscn")
var promotion_menu: PromotionMenu
var promotion_menu_enabled := false

@onready var grid_container = $Background/GridContainer
@onready var color_to_move_text = $Background/ColorToMoveText

var arrows: Array[Arrow]

var arrow_scene = preload ("res://scenes/arrow.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	# Used to update side to move
	EventBus.connect("piece_moved", _on_piece_move)
	var square_arr: Array[Square] = Board.get_square_arr()
	for square in square_arr:
		grid_container.add_child(square)
		
	update_color_to_move_text()

func draw_arrow(start_pos: Vector2, end_pos: Vector2):
	
	var arrow = arrow_scene.instantiate()
	arrows.append(arrow)
	add_child(arrow)

	arrow.init(start_pos, end_pos)
	
func clear_arrows():
	for arrow in arrows:
		arrow.queue_free()
	arrows = []

## Creates a promotion menu at the specified square
func create_promotion_menu(square: Square, piece_color: int):
	promotion_menu = promotion_menu_scene.instantiate()
	promotion_menu.piece_color = piece_color
	
	square.add_child(promotion_menu)

	promotion_menu_enabled = true

func delete_promotion_menu():
	if promotion_menu_enabled:
		promotion_menu.delete()
	promotion_menu_enabled = false
	
func _on_piece_move(_square):
	update_color_to_move_text()

func update_color_to_move_text():
	if Board.color_to_move == Board.PIECE_COLOR.WHITE:
		color_to_move_text.text = "Color to move: White"
	else:
		color_to_move_text.text = "Color to move: Black"
