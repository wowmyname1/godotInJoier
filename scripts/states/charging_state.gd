class_name ChargingState
extends CasterState

func _on_enter() -> void:
	super._on_enter()
	print("[ChargingState] Entered - Hold for perfect timing!")

func _on_input(event: InputEvent) -> void:
	if event.is_action_released("cast"):
		var cast_tier = _determine_cast_tier()
		state_finished.emit(cast_tier)
		print("[ChargingState] Released - ", cast_tier)

func _determine_cast_tier() -> String:
	if aspect_data == null:
		return "NaturalCast"
	
	if timer > aspect_data.max_charge_duration:
		return "OverCast"
	elif is_in_window(
		aspect_data.perfect_window_center,
		aspect_data.perfect_window_tolerance,
		timer
	):
		return "PerfectCast"
	elif timer < aspect_data.perfect_window_center:
		return "NaturalCast"
	else:
		return "NaturalCast"

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		if aspect_data.stagger_resistance <= 0:
			state_finished.emit("LowCast")
