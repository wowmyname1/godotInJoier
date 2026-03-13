class_name NaturalCastState
extends CasterState
## Естественное применение Аспекта.
## Join point для Channeling → NatureCast пути.
## Отправляет cast_completed для проверки Transition Conditions.

var natural_cast_duration: float = 0.5

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		natural_cast_duration = aspect_data.natural_cast_duration
	print("[NaturalCastState] Entered - Standard cast!")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	
	if timer >= natural_cast_duration:
		# Отправляем сигнал о завершении каста (для Transition Conditions)
		cast_completed.emit("NaturalCast")
		state_finished.emit("AfterCast")
		print("[NaturalCastState] Complete → AfterCast")

func _on_input(event: InputEvent) -> void:
	# Прерывание каста
	if event.is_action_pressed("cast"):
		state_finished.emit("MissCast")
		print("[NaturalCastState] Interrupted → MissCast")

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		state_finished.emit("MissCast")
		if owner_node != null and owner_node.has_method("reset_combo"):
			owner_node.reset_combo()
