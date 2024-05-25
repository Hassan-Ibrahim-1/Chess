class_name Piece

extends Node2D

enum PIECE_COLOR {
	WHITE = 0,
	BLACK = 1,
}

enum PIECE_TYPES {
	PAWN,
	BISHOP,
	KNIGHT,
	ROOK,
	QUEEN,
	KING,
}

# var occupied_square: Square
var piece_type: int
var piece_color: int

@onready var piece_icon = $PieceIcon

# Enabled when the mouse is clicked and hovers on a square that contains a piece
# Disabled when the mouse is released
var dragging_enabled: bool = false

# Offset to center the piece to the mouse
var drag_offset := Vector2(-50, -50)

# Sets up the values needed for a piece scene
# Called manually
func init(p_type: int = 0, p_color: int = 0):
	piece_type = p_type
	piece_color = p_color

# Called when the node enters the scene tree for the first time.
func _ready():
	#print_debug("Piece ready")
	EventBus.connect("click", _on_square_click)
	EventBus.connect("release", _on_square_release)
	set_icon()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	# If dragging is enabled - get mouse position and add drag_offset to it
	# Then set the resulting vector as the position of PieceIcon
	if dragging_enabled:
		var mouse_pos = get_local_mouse_position()
		var final_pos = mouse_pos + drag_offset
		piece_icon.set_position(final_pos)

func _on_square_click(square: Square):
	# Enables dragging when a square is clicked
	if square.piece_on_square == self:
		dragging_enabled = true
		z_index = 2
		
func _on_square_release(_square: Square):
	# Disables dragging when a square is released
	dragging_enabled = false
	z_index = 1
	
	# Sets the position of PieceIcon back to the position of Piece
	# When a piece is moved to another square the texture moves to that square
	# If not then it doesn't move
	piece_icon.set_position(position)

# Determines the icon of the piece based on type and color
# Sets it as the PieceIcon of the piece
# Determines the path of the image by using the following scheme:
# ('res://assets/{colornumber}{piecename}.png')
func set_icon():
	var piece_name: String
	
	match piece_type:
		
		PIECE_TYPES.PAWN:
			piece_name = "pawn"
		PIECE_TYPES.BISHOP:
			piece_name = "bishop"
		PIECE_TYPES.KNIGHT:
			piece_name = "knight"
		PIECE_TYPES.ROOK:	
			piece_name = "rook"
		PIECE_TYPES.QUEEN:
			piece_name = "queen"
		PIECE_TYPES.KING:
			piece_name = "king"      
		_:
			print_debug("Unexpected piece type")
			
	var texture_path = load("res://assets/" + str(piece_color) + piece_name + ".png")
	piece_icon.texture = texture_path
