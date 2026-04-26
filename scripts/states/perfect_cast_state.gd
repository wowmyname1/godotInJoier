class_name PerfectCastState
extends BaseCastState
## Идеальное применение Аспекта.
## Join point для Charging → PerfectCast пути.
## Отправляет cast_completed + increment_combo для Transition Conditions.

func _init():
	cast_tier_name = "PerfectCast"
	should_increment_combo = true
	reset_combo_on_interrupt = true
	reset_combo_on_damage = true

func _get_cast_duration() -> float:
	if aspect_data != null:
		return aspect_data.perfect_cast_duration
	return 0.7

func _get_enter_message() -> String:
	return "Perfect sync with Aspect!"
