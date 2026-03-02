class_name ChannelingState
extends CasterState

var channeling_duration: float = 0.5

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		channeling_duration = aspect_data.channeling_duration
	print("[ChannelingState] Entered - Ready for input!")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	if timer >= channeling_duration:
		state_finished.emit("LowCast")

func _on_input(event: InputEvent) -> void:
	if event.is_action_pressed("cast"):
		state_finished.emit("Charging")
		print("[ChannelingState] Input detected - Charging!")
	elif event.is_action_released("cast"):
		state_finished.emit("LowCast")

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		if aspect_data.stagger_resistance <= 0:
			state_finished.emit("LowCast")
