extends Node

# Left click signals
signal click(emitter)
signal release(emitter)

# Right click signals
signal right_click(position)
signal right_click_release(position, square)

# Signal emitted when a piece has been moved
# param is the square that the piece was moved to
signal piece_moved(target_square)
