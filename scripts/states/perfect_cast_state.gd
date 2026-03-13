class_name PerfectCastState
extends CasterState
## Идеальное применение Аспекта.
## Join point для Charging → PerfectCast пути.
## Отправляет cast_completed + increment_combo для Transition Conditions.

var perfect_cast_duration: float = 0.7

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		perfect_cast_duration = aspect_data.perfect_cast_duration
	print("[PerfectCastState] Entered - Perfect sync with Aspect!")
	
	# Увеличиваем комбо (при входе в состояние)
	if owner_node != null and owner_node.has_method("increment_combo"):
		owner_node.increment_combo()

func _on_update(delta: float) -> void:
	super._on_update(delta)
	
	if timer >= perfect_cast_duration:
		# Отправляем сигнал о завершении каста (для Transition Conditions)
		cast_completed.emit("PerfectCast")
		state_finished.emit("AfterCast")
		print("[PerfectCastState] Complete → AfterCast")

func _on_input(event: InputEvent) -> void:
	# Прерывание каста
	if event.is_action_pressed("cast"):
		state_finished.emit("MissCast")
		print("[PerfectCastState] Interrupted → MissCast")
		if owner_node != null and owner_node.has_method("reset_combo"):
			owner_node.reset_combo()

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		state_finished.emit("MissCast")
		if aspect_data.reset_combo_on_damage:
			if owner_node != null and owner_node.has_method("reset_combo"):
				owner_node.reset_combo()
