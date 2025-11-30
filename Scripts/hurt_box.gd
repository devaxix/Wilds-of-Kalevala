extends Area2D

# Update the function to accept the SECOND argument (source_pos)
# We set it to Vector2.ZERO by default, just in case something else calls it without a position.
func take_damage(amount, source_pos = Vector2.ZERO):
	if get_parent().has_method("take_damage"):
		# Pass BOTH the amount AND the position to the Skeleton
		get_parent().take_damage(amount, source_pos)
