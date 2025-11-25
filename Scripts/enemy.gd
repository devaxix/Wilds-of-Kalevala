extends CharacterBody2D

@export var speed: int = 40
@export var max_health: int = 2
var current_health: int = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1 

@onready var start_scale = abs(scale.x)

enum {WALK, ATTACK, HURT, DIE, IDLE_WAIT}
var state = WALK

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
@onready var attack_area = $AttackArea
@onready var detection_area = $DetectionArea 
@onready var wall_check = $WallCheck

func _ready():
	current_health = max_health
	anim_player.play("Walk")
	# FIX: Sync the raycast immediately
	update_raycast_direction()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	match state:
		WALK:
			move_logic()
			check_for_player()
		ATTACK, HURT, DIE, IDLE_WAIT:
			velocity.x = 0
	
	move_and_slide()

	# Visual Flipping
	if direction == 1:
		scale.x = start_scale 
	elif direction == -1:
		scale.x = -start_scale 

func move_logic():
	velocity.x = direction * speed
	
	# Wall Check Logic
	if wall_check.is_colliding():
		start_idle_wait()

func start_idle_wait():
	state = IDLE_WAIT
	velocity.x = 0
	anim_player.play("Idle")
	await get_tree().create_timer(2.0).timeout
	flip_direction()
	state = WALK
	anim_player.play("Walk")

func flip_direction():
	direction *= -1
	update_raycast_direction()

func update_raycast_direction():
	# Ensure the raycast always points forward
	if direction > 0:
		wall_check.target_position.x = abs(wall_check.target_position.x)
	else:
		wall_check.target_position.x = -abs(wall_check.target_position.x)

# --- DETECTION LOGIC (This was missing!) ---
func check_for_player():
	# 1. Get everyone inside the detection area
	# Ensure you have a node named "DetectionArea" and the variable is set up!
	var bodies = detection_area.get_overlapping_bodies()
	
	for body in bodies:
		# Check for Player by Name
		if body.name == "Player":
			start_attack(body)
			return 

func start_attack(target):
	state = ATTACK
	
	# Face the player immediately
	var direction_to_player = target.global_position.x - global_position.x
	
	if direction_to_player > 0:
		scale.x = start_scale # Face Right
		direction = 1 # Update walk direction
	else:
		scale.x = -start_scale # Face Left
		direction = -1

	# Random Attack
	var random_pick = randi() % 2
	if random_pick == 0:
		anim_player.play("Attack 1")
	else:
		anim_player.play("Attack 2")
	
	await anim_player.animation_finished
	
	state = WALK
	anim_player.play("Walk")

func _on_sword_hitbox_body_entered(body):
	# Debug Print: See what we are hitting!
	print("Sword hit: ", body.name) 
	
	if body.has_method("take_damage"):
		print("Dealing damage to enemy!")
		body.take_damage(1)
