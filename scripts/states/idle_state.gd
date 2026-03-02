class_name IdleState
extends CasterState

var idle_duration: float = 1.0

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		idle_duration = aspect_data.idle_duration
	print("[IdleState] Entered")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	if timer >= idle_duration:
		state_finished.emit("Invocation")

func _on_input(event: InputEvent) -> void:
	if event.is_action_pressed("cast"):
		
		timer = 0.0
		print("[IdleState] Input held - timer reset")

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		if aspect_data.stagger_resistance <= 0:
			state_finished.emit("MissCasting")
