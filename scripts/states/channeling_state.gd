class_name ChannelingState
extends CasterState
## Направление магии. Естественный поток.
## По таймеру → NatureCast (естественный каст).
## По нажатию → Charging (игрок вмешивается).

var channeling_duration: float = 0.5

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		channeling_duration = aspect_data.channeling_duration
	print("[ChannelingState] Entered - Natural flow...")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	
	# Естественный переход в NatureCast по таймеру
	if timer >= channeling_duration:
		state_finished.emit(StateNames.NATURAL_CAST)
		print("[ChannelingState] Timeout → NaturalCast")

func _on_input(event: InputEvent) -> void:
	# Игрок нажимает → переход в Charging
	if event.is_action_pressed("cast"):
		state_finished.emit("Charging")
		print("[ChannelingState] Mouse down → Charging")

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		if aspect_data.stagger_resistance <= 0:
			state_finished.emit("MissCast")
			if owner_node != null and owner_node.has_method("reset_combo"):
				owner_node.reset_combo()
