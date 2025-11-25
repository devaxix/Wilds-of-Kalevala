extends Area2D

# This function acts as a "Middleman"
# When the sword hits this Hurtbox, it calls this function.
# This function then tells the Parent (Skeleton) to take damage.
func take_damage(amount):
	if get_parent().has_method("take_damage"):
		get_parent().take_damage(amount)
