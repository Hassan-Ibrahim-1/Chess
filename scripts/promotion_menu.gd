class_name PromotionMenu

extends Control

@onready var queen_button: Button = $GridContainer/Queen
@onready var rook_button: Button = $GridContainer/Rook
@onready var knight_button: Button = $GridContainer/Knight
@onready var bishop_button: Button = $GridContainer/Bishop

var piece_color: int

func _ready():
	set_piece_color()
	position = Vector2(0, 0)

## Sets the piece color of the promotion pieces
func set_piece_color():
	if piece_color == Board.PIECE_COLOR.WHITE:
		queen_button.icon = load("res://assets/0queen.png")
		rook_button.icon = load("res://assets/0rook.png")
		knight_button.icon = load("res://assets/0knight.png")
		bishop_button.icon = load("res://assets/0bishop.png")

	else:
		queen_button.icon = load("res://assets/1queen.png")
		rook_button.icon = load("res://assets/1rook.png")
		bishop_button.icon = load("res://assets/1bishop.png")
		knight_button.icon = load("res://assets/1knight.png")
