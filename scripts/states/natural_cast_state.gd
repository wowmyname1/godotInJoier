class_name NaturalCastState
extends BaseCastState
## Естественное применение Аспекта.
## Join point для Channeling → NatureCast пути.
## Отправляет cast_completed для проверки Transition Conditions.

func _init():
	cast_tier_name = "NaturalCast"
	reset_combo_on_interrupt = false
	reset_combo_on_damage = false

func _get_cast_duration() -> float:
	if aspect_data != null:
		return aspect_data.natural_cast_duration
	return 0.5

func _get_enter_message() -> String:
	return "Standard cast!"
