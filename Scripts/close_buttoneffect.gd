extends TextureButton

# --- SETTINGS ---
@export var hover_scale := Vector2(1.1, 1.1)  # Grow 10% when hovered
@export var click_scale := Vector2(0.95, 0.95) # Shrink 5% when clicked
@export var tween_speed := 0.1

# --- INTERNAL VARIABLES ---
var original_y = 0
var default_scale := Vector2(1, 1)
var tween : Tween

func _ready():
	# 1. Remember starting position (for the click move)
	original_y = position.y
	default_scale = scale
	
	# 2. Set Pivot to Center (Crucial for scaling!)
	pivot_offset = size / 2
	
	# 3. Connect Signals
	button_down.connect(_on_pressed)
	button_up.connect(_on_released)
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)

# --- HOVER LOGIC ---
func _on_hover():
	animate_scale(hover_scale)
	# Optional: $HoverSound.play()

func _on_exit():
	animate_scale(default_scale)

# --- CLICK LOGIC ---
func _on_pressed():
	# 1. Move Down (Your logic)
	position.y = original_y + 4
	
	# 2. Scale Down (Juice)
	animate_scale(click_scale)

func _on_released():
	# 1. Snap Back Up
	position.y = original_y
	
	# 2. Scale Back (Check if we are still hovering)
	if is_hovered():
		animate_scale(hover_scale)
	else:
		animate_scale(default_scale)

# --- ANIMATION HELPER ---
func animate_scale(target_val):
	# Kill previous animation if running
	if tween: tween.kill()
	
	tween = create_tween()
	# "Back" trans makes it overshoot slightly (Bouncy!)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", target_val, tween_speed)
