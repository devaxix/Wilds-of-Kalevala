class_name PlayerController
extends CharacterBody2D



@export var speed = 10
@export var jump_power = 10

var speed_multiplier = 30
var jump_multiplier = -30 
var direction = 0

#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_power * jump_multiplier

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("Move Left", "Move Right")
	if direction:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	move_and_slide()

@export var max_health = 3
var current_health = 0
var has_sword = false
var is_attacking = false

func _ready():
	current_health = max_health
	# Initialize UI here (we can connect this later)

func take_damage(amount):
	current_health -= amount
	print("Player Health: ", current_health)
	if current_health <= 0:
		die()

func die():
	print("I remember... A sweet bliss.")
	# Reload scene or show game over screen
	get_tree().reload_current_scene()
