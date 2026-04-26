class_name OverCastState
extends BaseCastState
## Перезаряд Аспекта (риск/награда).
## Join point для Charging → OverCast пути.
## Отправляет cast_completed для проверки Transition Conditions.
## Наносит урон себе при входе (опционально).

func _init():
	cast_tier_name = "OverCast"
	should_apply_self_damage = true
	reset_combo_on_interrupt = true
	reset_combo_on_damage = false

func _get_cast_duration() -> float:
	if aspect_data != null:
		return aspect_data.perfect_cast_duration  # Или отдельное поле
	return 0.7

func _get_enter_message() -> String:
	return "Overcharged!"

func _handle_on_enter_effects() -> void:
	super._handle_on_enter_effects()
	
	# Дополнительная логика для OverCast (если нужно)
	if aspect_data != null and aspect_data.over_cast_self_damage > 0:
		self_damage_amount = aspect_data.over_cast_self_damage
