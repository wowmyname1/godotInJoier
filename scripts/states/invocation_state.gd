class_name InvocationState
extends CasterState

var invocation_duration: float = 0.4

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		invocation_duration = aspect_data.invocation_duration
	print("[InvocationState] Entered - Calling Aspect...")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	if timer >= invocation_duration:
		state_finished.emit("Channeling")

func _on_input(event: InputEvent) -> void:
	if event.is_action_pressed("cast"):
		state_finished.emit("LowCast")
		print("[InvocationState] Interrupted!")
		if owner_node != null and owner_node.has_method("reset_combo"):
			owner_node.reset_combo()

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		if aspect_data.stagger_resistance <= 0:
			state_finished.emit("LowCast")
