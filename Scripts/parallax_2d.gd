extends Parallax2D

# Base speed (px/s) that the fastest layer will move
@export var base_scroll_speed: float = 30.0 
var layers = [] 
const TILE_WIDTH = 512.0 # Your texture width for looping

func _ready():
	# Finds all layers (in your case, just the one Sprite2D)
	for child in get_children():
		if child is Sprite2D:
			# Attach a speed scale directly to the node's metadata
			# We'll set the speed scale to 1.0 (full speed) for testing
			child.set_meta("scroll_scale", 1.0) 
			layers.append(child)
	
	if layers.is_empty():
		print("ERROR: No Sprite2D layers found to move.")


func _process(delta):
	# Loop through all layers found
	for layer in layers:
		# 1. Calculate the layer's speed (30.0 * 1.0 = 30.0 px/s)
		var scale = layer.get_meta("scroll_scale")
		var speed = base_scroll_speed * scale
		
		# 2. Apply movement (using negative for scrolling left)
		layer.position.x -= speed * delta
		
		# 3. Handle Clipping/Infinite Loop
		# When the layer moves one tile width left, reset its position to keep the offset small.
		if layer.position.x <= -TILE_WIDTH:
			layer.position.x += TILE_WIDTH
