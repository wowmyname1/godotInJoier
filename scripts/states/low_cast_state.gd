class_name LowCastState
extends CasterState

var low_cast_duration: float = 0.3

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		low_cast_duration = aspect_data.low_cast_duration
	print("[LowCastState] Entered - Weak cast!")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	if timer >= low_cast_duration:
		state_finished.emit("AfterCast")

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		state_finished.emit("LowCast")
