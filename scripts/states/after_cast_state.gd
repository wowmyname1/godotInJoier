class_name AfterCastState
extends CasterState
## Восстановление после каста.
## По таймеру → Channeling (цикл продолжается).
## По нажатию → MissCast (прерывание цикла).

var after_cast_duration: float = 0.3

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		after_cast_duration = aspect_data.after_cast_duration
	print("[AfterCastState] Entered - Recovery...")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	
	# По таймеру возврат в Channeling (цикл продолжается!)
	if timer >= after_cast_duration:
		state_finished.emit("Channeling")
		print("[AfterCastState] Timeout → Channeling (cycle continues)")

func _on_input(event: InputEvent) -> void:
	# Прерывание цикла
	if event.is_action_pressed("cast"):
		state_finished.emit("MissCast")
		print("[AfterCastState] Interrupted → MissCast")

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		state_finished.emit("MissCast")
