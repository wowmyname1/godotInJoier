class_name BaseCastState
extends CasterState
## Базовый класс для состояний каста (Low/Perfect/Over/Natural).
## Устраняет дублирование кода между состояниями каста.
## Дочерние классы переопределяют только специфичную логику.

# ─────────────────────────────────────────────────────────────────────────────
# ПЕРЕМЕННЫЕ
# ─────────────────────────────────────────────────────────────────────────────

var cast_duration: float = 0.5
## Длительность каста (переопределяется в дочерних классах или aspect_data)

var cast_tier_name: String = "BaseCast"
## Имя уровня каста для сигнала cast_completed

var should_increment_combo: bool = false
## Увеличивать ли комбо при входе в состояние

var should_apply_self_damage: bool = false
## Наносить ли урон себе при входе в состояние

var self_damage_amount: int = 0
## Количество урона себе (если should_apply_self_damage = true)

var reset_combo_on_interrupt: bool = true
## Сбрасывать ли комбо при прерывании каста

var reset_combo_on_damage: bool = false
## Сбрасывать ли комбо при получении урона

# ─────────────────────────────────────────────────────────────────────────────
# ВИРТУАЛЬНЫЕ МЕТОДЫ (Переопределяются в дочерних классах)
# ─────────────────────────────────────────────────────────────────────────────

func _get_cast_duration() -> float:
	## Получить длительность каста из aspect_data или использовать значение по умолчанию.
	## Переопределяется в дочерних классах для выбора нужного поля из aspect_data.
	return cast_duration

func _on_cast_complete() -> void:
	## Вызывается при завершении каста (когда timer >= cast_duration).
	## Переопределяется для дополнительной логики перед отправкой сигналов.
	pass

func _get_next_state() -> String:
	## Получить имя следующего состояния после завершения каста.
	## По умолчанию переходит в AfterCast.
	return "AfterCast"

# ─────────────────────────────────────────────────────────────────────────────
# БАЗОВАЯ ЛОГИКА
# ─────────────────────────────────────────────────────────────────────────────

func _on_enter() -> void:
	super._on_enter()
	
	# Получаем длительность каста из aspect_data
	cast_duration = _get_cast_duration()
	
	# Логика при входе в состояние
	_handle_on_enter_effects()
	
	print("[%s] Entered - %s" % [cast_tier_name, _get_enter_message()])

func _handle_on_enter_effects() -> void:
	## Обработка эффектов при входе в состояние (комбо, урон и т.д.)
	
	# Увеличение комбо (если требуется)
	if should_increment_combo and owner_node != null and owner_node.has_method("increment_combo"):
		owner_node.increment_combo()
	
	# Нанесение урона себе (если требуется)
	if should_apply_self_damage and self_damage_amount > 0:
		if owner_node != null and owner_node.has_method("handle_damage"):
			owner_node.handle_damage(self_damage_amount)
			print("[%s] Self-damage: %d" % [cast_tier_name, self_damage_amount])

func _get_enter_message() -> String:
	## Сообщение при входе в состояние (переопределяется в дочерних классах).
	return "Casting..."

func _on_update(delta: float) -> void:
	super._on_update(delta)
	
	if timer >= cast_duration:
		# Дополнительная логика перед завершением каста
		_on_cast_complete()
		
		# Отправляем сигнал о завершении каста (для Transition Conditions)
		cast_completed.emit(cast_tier_name)
		
		# Переходим в следующее состояние
		var next_state = _get_next_state()
		state_finished.emit(next_state)
		print("[%s] Complete → %s" % [cast_tier_name, next_state])

func _on_input(event: InputEvent) -> void:
	# Прерывание каста по вводу
	if event.is_action_pressed("cast"):
		_interrupt_cast()

func _interrupt_cast() -> void:
	## Прервать каст и перейти в MissCast
	state_finished.emit("MissCast")
	print("[%s] Interrupted → MissCast" % [cast_tier_name])
	
	if reset_combo_on_interrupt and owner_node != null and owner_node.has_method("reset_combo"):
		owner_node.reset_combo()

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		state_finished.emit("MissCast")
		
		# Сброс комбо при получении урона (если настроено)
		var should_reset = reset_combo_on_damage or (aspect_data.has_method("get_reset_combo_on_damage") and aspect_data.reset_combo_on_damage)
		if should_reset and owner_node != null and owner_node.has_method("reset_combo"):
			owner_node.reset_combo()
