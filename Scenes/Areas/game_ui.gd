extends CanvasLayer

# Assign these in the Inspector!
@export var full_heart : Texture2D
@export var empty_heart : Texture2D

# Grab the container so we can find the children
@onready var heart_container = $HBoxContainer

func update_hearts(current_health: int):
	# Get all the TextureRects (children of the container)
	var hearts = heart_container.get_children()
	
	for i in range(hearts.size()):
		if i < current_health:
			hearts[i].texture = full_heart # Alive heart
		else:
			hearts[i].texture = empty_heart # Dead/Empty heart
