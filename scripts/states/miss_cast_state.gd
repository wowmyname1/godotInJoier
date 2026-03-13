class_name MissCastState
extends CasterState
## Штраф за прерывание цикла заклинания.

var miss_cast_duration: float = 0.8

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		miss_cast_duration = aspect_data.miss_cast_duration
	print("[MissCastState] Entered - Penalty!")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	
	# Проверяем кнопку в конце таймера
	if timer >= miss_cast_duration:
		if Input.is_action_pressed("cast"):
			# Удерживает → InvocationFailed
			state_finished.emit("InvocationFailed")
			print("[MissCastState] Button held → InvocationFailed")
		else:
			# Не удерживает → возврат в Channeling
			state_finished.emit("Channeling")
			print("[MissCastState] Button released → Channeling")
