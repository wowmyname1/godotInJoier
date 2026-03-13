class_name InvocationState
extends CasterState
## Призыв Аспекта. Проигрывается анимация.
## Успех только если кнопка отпущена к концу таймера.
## Удержание зацикливает анимацию (макс. max_hold_cycles).
## Спам кнопки (Up+Down до конца) = штраф.

var invocation_duration: float = 0.4
var hold_cycles: int = 0
var max_hold_cycles: int = 3
var was_released: bool = false

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		invocation_duration = aspect_data.invocation_duration
		max_hold_cycles = aspect_data.max_hold_cycles
	hold_cycles = 0
	was_released = false
	print("[InvocationState] Entered - Calling Aspect...")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	
	# Проверяем состояние кнопки
	if Input.is_action_pressed("cast"):
		# Кнопка удерживается
		if timer >= invocation_duration:
			# Анимация закончилась, но кнопка всё ещё нажата
			hold_cycles += 1
			print("[InvocationState] Hold cycle: ", hold_cycles, "/", max_hold_cycles)
			
			if hold_cycles >= max_hold_cycles:
				# Слишком долго держит
				state_finished.emit("InvocationFailed")
				print("[InvocationState] Too many hold cycles → InvocationFailed")
			else:
				# Зацикливаем анимацию (сбрасываем таймер)
				timer = 0.0
	else:
		# Кнопка отпущена
		was_released = true
		
		# Проверяем, успели ли до конца анимации
		if timer >= invocation_duration:
			# Успешная инвокация
			state_finished.emit("Channeling")
			print("[InvocationState] Success → Channeling")

func _on_input(event: InputEvent) -> void:
	# Детекция спама кнопки (отпустил + нажал до конца анимации)
	if event.is_action_released("cast"):
		was_released = true
	elif event.is_action_pressed("cast") and was_released and timer < invocation_duration:
		# Игрок успел отпустить и нажать ещё раз до конца анимации
		state_finished.emit("InvocationFailed")
		print("[InvocationState] Button spam → InvocationFailed")
		if owner_node != null and owner_node.has_method("reset_combo"):
			owner_node.reset_combo()

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		if aspect_data.stagger_resistance <= 0:
			state_finished.emit("MissCast")
			if owner_node != null and owner_node.has_method("reset_combo"):
				owner_node.reset_combo()
