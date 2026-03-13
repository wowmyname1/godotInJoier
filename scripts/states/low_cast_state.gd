class_name LowCastState
extends CasterState
## Слабое применение Аспекта (ранний релиз).
## Join point для Charging → LowCast пути.
## Отправляет cast_completed для проверки Transition Conditions.

var low_cast_duration: float = 0.3

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		low_cast_duration = aspect_data.low_cast_duration
	print("[LowCastState] Entered - Weak cast!")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	
	if timer >= low_cast_duration:
		# Отправляем сигнал о завершении каста (для Transition Conditions)
		cast_completed.emit("LowCast")
		state_finished.emit("AfterCast")
		print("[LowCastState] Complete → AfterCast")

func _on_input(event: InputEvent) -> void:
	# Прерывание каста
	if event.is_action_pressed("cast"):
		state_finished.emit("MissCast")
		print("[LowCastState] Interrupted → MissCast")
		if owner_node != null and owner_node.has_method("reset_combo"):
			owner_node.reset_combo()

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		state_finished.emit("MissCast")
		if owner_node != null and owner_node.has_method("reset_combo"):
			owner_node.reset_combo()
