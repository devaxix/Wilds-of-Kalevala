extends AnimatedSprite2D

@export var run_speed = 100
@export var start_delay = 8.0

var is_running = false

# Reference to the Notifier so we know when to delete him
@onready var notifier = $VisibleOnScreenNotifier2D

func _ready():
	# 1. Start Sleeping immediately
	play("Sleep") # Capitalized as you requested!
	
	# 2. Connect the "Exit Screen" signal automatically
	# When he leaves the screen, call '_on_screen_exited'
	notifier.screen_exited.connect(_on_screen_exited)
	
	# 3. Start the timer to wake up
	start_sequence()

func start_sequence():
	# Wait for the delay
	await get_tree().create_timer(start_delay).timeout
	
	# Wake up
	play("Wake")
	await animation_finished
	
	# Run!
	play("Run")
	is_running = true

func _process(delta):
	if is_running:
		# Move to the right
		position.x += run_speed * delta

func _on_screen_exited():
	# He is gone. Delete him forever.
	queue_free()
