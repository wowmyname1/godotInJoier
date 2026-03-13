class_name OverCastState
extends CasterState
## Перезаряд Аспекта (риск/награда).
## Join point для Charging → OverCast пути.
## Отправляет cast_completed для проверки Transition Conditions.
## Наносит урон себе при входе (опционально).

var over_cast_duration: float = 0.7

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		over_cast_duration = aspect_data.perfect_cast_duration  # Или отдельное поле
	
	print("[OverCastState] Entered - Overcharged!")
	
	# Наносим урон себе (опционально, согласно aspect_data)
	if aspect_data != null and aspect_data.over_cast_self_damage > 0:
		if owner_node != null and owner_node.has_method("handle_damage"):
			owner_node.handle_damage(aspect_data.over_cast_self_damage)
			print("[OverCastState] Self-damage: ", aspect_data.over_cast_self_damage)

func _on_update(delta: float) -> void:
	super._on_update(delta)
	
	if timer >= over_cast_duration:
		# Отправляем сигнал о завершении каста (для Transition Conditions)
		cast_completed.emit("OverCast")
		state_finished.emit("AfterCast")
		print("[OverCastState] Complete → AfterCast")

func _on_input(event: InputEvent) -> void:
	# Прерывание каста
	if event.is_action_pressed("cast"):
		state_finished.emit("MissCast")
		print("[OverCastState] Interrupted → MissCast")
		if owner_node != null and owner_node.has_method("reset_combo"):
			owner_node.reset_combo()

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		state_finished.emit("MissCast")
		if owner_node != null and owner_node.has_method("reset_combo"):
			owner_node.reset_combo()
