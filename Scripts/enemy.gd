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
	# SAFETY: Ensure we start with the health from the Inspector
	current_health = max_health
	print("SKELETON SPAWNED. HEALTH: ", current_health) # Debug Check
	
	anim_player.play("Walk")

func _physics_process(delta):
	# Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# STATE MACHINE
	match state:
		WALK:
			move_logic()
			check_for_player()
		ATTACK:
			velocity.x = 0
		HURT:
			velocity.x = 0
		DIE:
			velocity.x = 0
			velocity.y = 0 # Stop falling if you want
		IDLE_WAIT:
			velocity.x = 0
	
	move_and_slide()

	# VISUAL FLIPPING (Only flip if alive and moving)
	if state == WALK:
		if velocity.x > 1:
			scale.x = start_scale 
		elif velocity.x < -1:
			scale.x = -start_scale 

func move_logic():
	velocity.x = direction * speed
	if wall_check.is_colliding():
		start_idle_wait()

func start_idle_wait():
	state = IDLE_WAIT
	velocity.x = 0
	anim_player.play("Idle")
	await get_tree().create_timer(2.0).timeout
	
	# CRITICAL CHECK: Did we die while waiting?
	if state == DIE: return
	
	flip_direction()
	state = WALK
	anim_player.play("Walk")

func flip_direction():
	direction *= -1

func check_for_player():
	var bodies = detection_area.get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			start_attack(body)
			return 

func start_attack(target):
	state = ATTACK
	
	# Face Player
	var direction_to_player = target.global_position.x - global_position.x
	if direction_to_player > 0:
		scale.x = start_scale
		direction = 1 
	else:
		scale.x = -start_scale 
		direction = -1

	# Random Attack
	if randi() % 2 == 0:
		anim_player.play("Attack 1")
	else:
		anim_player.play("Attack 2")
	
	await anim_player.animation_finished
	
	# CRITICAL CHECK: Did we die mid-attack?
	if state == DIE: return
	
	state = WALK
	anim_player.play("Walk")

# --- THE DAMAGE FIX ---
func take_damage(amount):
	# 1. IGNORE if already dead or currently getting hurt
	if state == DIE or state == HURT:
		return
	
	current_health -= amount
	print("💥 HIT! Health left: ", current_health)
	
	if current_health <= 0:
		die()
	else:
		# 2. HURT LOGIC
		state = HURT
		print("🤕 Playing Hurt Animation.")
		anim_player.play("Hurt")
		
		await anim_player.animation_finished
		
		# 3. THE ZOMBIE FIX:
		# If we died while the animation was playing, STOP HERE.
		if state == DIE:
			return
			
		state = WALK
		anim_player.play("Walk")

func die():
	print("💀 SKELETON DYING...")
	state = DIE
	
	# Stop everything immediately
	anim_player.stop()
	anim_player.play("Die")
	
	# Turn off AI brain
	if has_node("DetectionArea"):
		$DetectionArea.monitoring = false
	
	# Turn off collision so we can walk through him
	set_collision_layer_value(3, false)
	
	# STOP PHYSICS: This guarantees he cannot walk again
	set_physics_process(false)
	
	await anim_player.animation_finished
	await get_tree().create_timer(2.0).timeout
	queue_free()
