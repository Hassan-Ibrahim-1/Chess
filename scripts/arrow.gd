class_name Arrow

extends Node2D

@onready var arrow_body = $ArrowBody
@onready var arrow_head = $ArrowHead

## Sets up the arrow
func init(p_start: Vector2, p_end: Vector2):
	
	# Used for the length of the arrow body
	# Distance between the starting and end points
	# Acts as the hypoteneuse
	var distance = abs(p_start.distance_to(p_end))
	
	# Setting the new size of the arrowbody
	arrow_body.size = Vector2(arrow_body.size.x, distance)
	
	# Setting up the position of the arrow
	# X value is the starting x value
	# Y value is the target square y value
	position.x = p_start.x
	position.y = p_end.y
	
	# Vertical leg of the triangle
	# Calculated using the difference of the y component of the two points
	var vertical_leg: float = abs(p_end.y - p_start.y)
	
	# Processing rotation - rotation that is still being processed
	var p_rotation = acos(vertical_leg / distance)
	
	# Flip the angle when the direction is negative
	# Right -> left
	if p_end.x < p_start.x:
		p_rotation = -p_rotation
	
	# adjust the x value based on rotation
	# Find the length of the opposite side and add it to position.x
	position.x += sin(p_rotation) * distance
	
	rotation = p_rotation
	
	# If the start square is above the target square
	# Rotate the arrow downwards - do this using vertical angles
	if p_start.y < p_end.y:
		rotation_degrees = 180 - rotation_degrees
