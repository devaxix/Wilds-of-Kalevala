extends Control

@export var scroll_speed = 100 # Pixels per second
@onready var scroll_container = $ScrollContainer

func _process(delta):
	# Scroll the container's vertical scrollbar upwards
	# Value of 0 is the top, max_scroll is the bottom.
	scroll_container.scroll_vertical -= scroll_speed * delta

	# Check if credits finished scrolling (scrollbar reaches the top)
	if scroll_container.scroll_vertical <= 0:
		# Optionally wait a few seconds, then return to the main menu
		# For simplicity, we'll return immediately here
		get_tree().change_scene_to_file("res://Scenes/Areas/main_menu.tscn")
