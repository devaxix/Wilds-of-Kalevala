extends Control

# Note: Adjust the path below if your main menu is stored elsewhere!
const MAIN_MENU_PATH = "res://Scenes/Areas/main_menu.tscn"

@onready var scroll_container: ScrollContainer = $ColorRect/ScrollContainer

@export var scroll_speed: float = 80.0 
@export var return_delay: float = 3.0 

var credits_finished: bool = false
var timer: float = 0.0

func _process(delta: float):
	# Retrieve the maximum scroll value directly from the scrollbar.
	var max_scroll_value = scroll_container.get_v_scroll_bar().max_value
	
	if not credits_finished:
		# Scroll downwards (by adding)
		scroll_container.scroll_vertical += scroll_speed * delta 
		
		# Now comparing the scroll position directly against the max value.
		if scroll_container.scroll_vertical >= max_scroll_value - 1.0:
			credits_finished = true
			print("Credits have finished scrolling down!")
	
	elif credits_finished:
		# Once scrolling is done, the timer starts
		timer += delta
		if timer >= return_delay:
			get_tree().change_scene_to_file(MAIN_MENU_PATH)


func _on_back_button_pressed() :
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
