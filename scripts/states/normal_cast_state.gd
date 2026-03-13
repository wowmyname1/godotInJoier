class_name NormalCastingState
extends CasterState

var normal_cast_duration: float = 0.5

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		normal_cast_duration = aspect_data.normal_cast_duration
	print("[NormalCastingState] Entered - Standard cast!")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	if timer >= normal_cast_duration:
		state_finished.emit("Aftercasting")

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		state_finished.emit("MissCast")
