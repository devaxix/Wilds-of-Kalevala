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
@onready var wall_check = $WallCheck # <--- NEW SENSOR
@onready var animation_player = $AnimationPlayer

func _ready():
	current_health = max_health
	anim_player.play("Walk")
	# Ensure raycast points the right way at start
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

	# --- VISUAL FLIPPING ---
	if velocity.x > 0:
		scale.x = start_scale 
	elif velocity.x < 0:
		scale.x = -start_scale 

func move_logic():
	velocity.x = direction * speed
	
	# --- NEW WALL CHECK ---
	# We ask the RayCast: "Are you hitting a wall?"
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
	# Make sure the sensor points the way we are walking
	if direction > 0:
		wall_check.target_position.x = abs(wall_check.target_position.x)
	else:
		wall_check.target_position.x = -abs(wall_check.target_position.x)

# --- DETECTION LOGIC (Same as before) ---
func check_for_player():
	var bodies = detection_area.get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			start_attack(body)
			return 

func start_attack(target):
	state = ATTACK
	
	var direction_to_player = target.global_position.x - global_position.x
	
	if direction_to_player > 0:
		scale.x = start_scale
		direction = 1 
	else:
		scale.x = -start_scale
		direction = -1
	
	# Update the raycast immediately so we don't turn around after attacking
	update_raycast_direction()

	if randi() % 2 == 0:
		anim_player.play("Attack 1")
	else:
		anim_player.play("Attack 2")
	
	await anim_player.animation_finished
	state = WALK
	anim_player.play("Walk")

# --- DAMAGE LOGIC (Same as before) ---
func take_damage(amount):
	if state == DIE: return
	current_health -= amount
	if current_health <= 0:
		die()
	else:
		state = HURT
		anim_player.play("Hurt")
		await anim_player.animation_finished
		state = WALK
		anim_player.play("Walk")

func die():
	state = DIE
	anim_player.play("Die")
	$BodyCollision.set_deferred("disabled", true)
	await anim_player.animation_finished
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _on_attack_area_body_entered(body: Node2D):
	if body.name == "Player":
		body.take_damage(1)
