extends ColorRect

class_name Square

@export var alternate_color: Color
@export var highlight_color: Color
@export var enable_alternate_color: bool

var default_color: Color = color
var ID: int
var piece_on_square: Piece = null # Null if there is no piece
var is_highlighted: bool = false
# Used to add an indicator to display whether a piece can move to this square or not
var indicate_legal_move: bool = false

func set_alternate_color():
	color = alternate_color
	default_color = alternate_color
	
func set_highlight_color():
	color = highlight_color
	is_highlighted = true
	
func set_default_color():
	color = default_color
	is_highlighted = false
	
func remove_piece():
	if piece_on_square != null:
		remove_child(get_children()[0])
	piece_on_square = null

func add_piece(piece: Piece) -> bool:
	# Returns true if successful - if there was no piece on the square previously
	# Returns false if there was a piece on the square
	if piece_on_square == null:
		piece_on_square = piece
		add_child(piece)
		
		return true
		
	return false
	
func replace_piece(piece: Piece):
	# Gets rid of the piece on the square and replaces it with the one specified
	remove_piece()
	add_piece(piece)
	
func _input(event):
	
	# If square has been clicked
	if event.is_action_pressed("mouse_click"):
		if get_rect().has_point(event.position):
			EventBus.click.emit(self)
			
	# If mouse has been released on square - used for dragging pieces
	elif event.is_action_released("mouse_click"):
		if get_rect().has_point(event.position):
			EventBus.release.emit(self)
	
	# If RMB has been clicked on a square - used for starting the creation of an arrow and
	# for determining the starting square which would be the square that released this signal
	elif event.is_action_pressed("mouse_right_click"):
		if get_rect().has_point(event.position):
			EventBus.right_click.emit(get_global_mouse_position())
	
	# IF RMB has been released on a square - used for determining the target square of an arrow
	elif event.is_action_released("mouse_right_click"):
		if get_rect().has_point(event.position):
			EventBus.right_click_release.emit(get_global_mouse_position(), self)
