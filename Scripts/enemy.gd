extends CharacterBody2D

@export var speed: int = 120
@export var max_health: int = 3
var current_health: int = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var direction: int = 1 # 1 = Right, -1 = Left


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
	
	# NEW: Ensure he looks the correct way immediately on spawn
	if direction == 1:
		scale.x = start_scale
	else:
		scale.x = -start_scale

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

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
		IDLE_WAIT:
			velocity.x = 0
	
	move_and_slide()

	# VISUAL FLIP
	if direction == 1:
		scale.x = start_scale 
	elif direction == -1:
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
	if state == DIE: return # Don't wake up if dead
	flip_direction()
	state = WALK
	anim_player.play("Walk")

func flip_direction():
	direction *= -1

# --- DETECTION ---
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

	if randi() % 2 == 0:
		anim_player.play("Attack 1")
	else:
		anim_player.play("Attack 2")
	
	await anim_player.animation_finished
	if state == DIE: return
	state = WALK
	anim_player.play("Walk")

# --- DAMAGE (Flash White Version) ---
func take_damage(amount):
	# 1. INVINCIBILITY CHECK
	# Ignore hits if already dying or currently playing hurt animation
	if state == DIE or state == HURT: 
		return
	
	current_health -= amount
	print("💥 HIT! Health left: ", current_health)
	
	if current_health <= 0:
		die()
	else:
		# 2. PLAY HURT ANIMATION
		print("🤕 Playing Hurt Animation")
		state = HURT
		
		# Play the animation you made!
		anim_player.play("Hurt")
		
		# Wait for it to finish
		await anim_player.animation_finished
		
		# 3. Return to Walk (only if still alive)
		if state != DIE:
			state = WALK
			anim_player.play("Walk")

func die():
	state = DIE
	anim_player.stop()
	anim_player.play("Die")
	
	if has_node("DetectionArea"): $DetectionArea.monitoring = false
	set_collision_layer_value(3, false)
	set_physics_process(false)
	
	await anim_player.animation_finished
	await get_tree().create_timer(2.0).timeout
	queue_free()

# --- ATTACK SIGNAL (Hurts the Player) ---
func _on_attack_area_body_entered(body: Node2D):
	if body.name == "Player":
		# Pass our position so player flies back
		if body.has_method("take_damage"):
			body.take_damage(1, global_position)
