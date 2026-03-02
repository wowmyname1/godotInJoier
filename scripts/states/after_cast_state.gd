class_name AfterCastState
extends CasterState

var after_cast_duration: float = 0.3

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		after_cast_duration = aspect_data.after_cast_duration
	print("[AfterCastState] Entered - Recovery...")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	if timer >= after_cast_duration:
		state_finished.emit("Channeling")

func _on_damage(amount: int) -> void:
	pass
