extends AnimatedSprite2D

@export var run_speed = 100
@export var start_delay = 8.0

var is_running = false

# Reference to the Notifier so we know when to delete him
@onready var notifier = $VisibleOnScreenNotifier2D
# Reference to the new sound player
@onready var fox_run_sound: AudioStreamPlayer2D = $FoxRunSound
# Reference to the new delay timer
@onready var sound_delay_timer: Timer = $SoundDelayTimer


func _ready():
	# 1. Start Sleeping immediately
	play("Sleep") # Capitalized as you requested!
	
	# 2. Connect the "Exit Screen" signal
	# When he leaves the screen, call the function that starts the delay timer
	notifier.screen_exited.connect(_on_screen_exited)
	
	# 3. Connect the "Enter Screen" signal
	notifier.screen_entered.connect(_on_screen_entered)
	
	# 4. Connect the Timer's timeout signal (connect this in the editor for cleaner code)
	sound_delay_timer.timeout.connect(_on_sound_delay_timer_timeout)
	
	# 5. Start the timer to wake up
	start_sequence()


# --- Sound Control Functions ---

func _on_screen_entered():
	# If the fox is running, and the timer was counting down, stop the timer.
	sound_delay_timer.stop()
	
	# If he is running, make sure the sound is playing (useful if he reappears).
	if is_running and not fox_run_sound.is_playing():
		fox_run_sound.play()

func _on_screen_exited():
	# Fox is gone. Start the timer to stop the sound after 2-3 seconds.
	sound_delay_timer.start()

func _on_sound_delay_timer_timeout():
	# The delay is over. Now, stop the sound.
	if fox_run_sound.is_playing():
		fox_run_sound.stop()
		
	# Now that the sound is definitely off, remove the fox.
	# We move the queue_free() logic here to ensure the sound stops first.
	queue_free()


# --- Existing Movement & Animation Logic ---

func start_sequence():
	# Wait for the delay
	await get_tree().create_timer(start_delay).timeout
	
	# Wake up
	play("Wake")
	await animation_finished
	
	# Run!
	play("Run")
	is_running = true
	
	# Start sound immediately when he starts running
	if fox_run_sound:
		fox_run_sound.play()

func _process(delta):
	if is_running:
		# Move to the right
		position.x += run_speed * delta

# func _on_screen_exited():
# 	# NOTE: The queue_free() call is now handled by the Timer's timeout function!
# 	queue_free()
