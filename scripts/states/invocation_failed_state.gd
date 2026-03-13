class_name InvocationFailedState
extends CasterState
## Состояние штрафа за неудачный призыв Аспекта.
## Переходит в Idle (если кнопка удерживается) или повторный Invocation (если отпущена).

var failed_duration: float = 0.8

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		failed_duration = aspect_data.invocation_failed_duration
	print("[InvocationFailedState] Entered - Invocation failed!")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	
	# Проверяем кнопку в конце таймера
	if timer >= failed_duration:
		if Input.is_action_pressed("cast"):
			# Кнопка удерживается → сброс в Idle
			state_finished.emit("Idle")
			print("[InvocationFailedState] Button held → Idle")
		else:
			# Кнопка не нажата → повторная попытка
			state_finished.emit("Invocation")
			print("[InvocationFailedState] Button released → Retry Invocation")

func _on_input(event: InputEvent) -> void:
	# Ввод не обрабатываем, всё решается в _on_update по таймеру
	pass

func _on_damage(amount: int) -> void:
	# Игнорируем урон (уже штраф)
	pass
