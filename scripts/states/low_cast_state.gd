class_name LowCastState
extends BaseCastState
## Слабое применение Аспекта (ранний релиз).
## Join point для Charging → LowCast пути.
## Отправляет cast_completed для проверки Transition Conditions.

func _init():
	cast_tier_name = "LowCast"
	reset_combo_on_interrupt = true
	reset_combo_on_damage = false

func _get_cast_duration() -> float:
	if aspect_data != null:
		return aspect_data.low_cast_duration
	return 0.3

func _get_enter_message() -> String:
	return "Weak cast!"
