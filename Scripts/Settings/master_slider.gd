extends HSlider

func _on_volume_changed(value):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
