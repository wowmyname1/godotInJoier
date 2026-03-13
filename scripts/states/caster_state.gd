class_name CasterState
extends Node
## Базовый класс для всех состояний заклинателя (FSM).
## Все конкретные состояния наследуются от этого класса.

# ─────────────────────────────────────────────────────────────────────────────
# СИГНАЛЫ
# ─────────────────────────────────────────────────────────────────────────────

@warning_ignore("unused_signal")
signal state_finished(next_state_name: String)
## Отправляется, когда состояние хочет перейти в другое состояние.

@warning_ignore("unused_signal")
signal cast_completed(cast_tier: String)
## Отправляется, когда каст завершён (для проверки Transition Conditions).

# ─────────────────────────────────────────────────────────────────────────────
# ПЕРЕМЕННЫЕ
# ─────────────────────────────────────────────────────────────────────────────

var aspect_data: AspectData
## Ссылка на ресурс с настройками Аспекта.

var timer: float = 0.0
## Локальный таймер состояния (в секундах).

var owner_node: Node = null
## Ссылка на владельца (AspectManager) — для доступа к другим компонентам.

# ─────────────────────────────────────────────────────────────────────────────
# ВИРТУАЛЬНЫЕ МЕТОДЫ (Переопределяются в дочерних классах)
# ─────────────────────────────────────────────────────────────────────────────

func _on_enter() -> void:
	## Вызывается при входе в состояние.
	## Дочерние классы должны вызывать super._on_enter() для сброса таймера.
	timer = 0.0

func _on_exit() -> void:
	## Вызывается при выходе из состояния.
	## Для очистки временных данных (анимации, звуки и т.д.).
	pass

func _on_update(delta: float) -> void:
	## Вызывается каждый кадр.
	## Дочерние классы должны вызывать super._on_update(delta) для работы таймера.
	timer += delta

func _on_input(event: InputEvent) -> void:
	## Вызывается при вводе игрока.
	## Дочерние классы решают, реагировать на ввод или игнорировать.
	pass

func _on_damage(amount: int) -> void:
	## Вызывается при получении урона.
	## Дочерние классы решают, прерывать ли состояние.
	pass

# ─────────────────────────────────────────────────────────────────────────────
# ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
# ─────────────────────────────────────────────────────────────────────────────

func is_in_window(center: float, tolerance: float, current_time: float) -> bool:
	## Проверка, находится ли текущее время в целевом окне.
	## Пример: is_in_window(0.5, 0.05, 0.47) → true (0.47 в окне 0.5 ± 0.05)
	return current_time >= (center - tolerance) and current_time <= (center + tolerance)

func set_owner_node(node: Node) -> void:
	## Установить ссылку на владельца (вызывается AspectManager при создании).
	owner_node = node

func get_manager() -> Node:
	## Получить ссылку на AspectManager (удобно для доступа к комбо и т.д.).
	return owner_node

func get_cast_direction() -> Vector2:
	## Получить направление каста (от игрока к курсору).
	## Требует, чтобы owner_node имел метод get_global_mouse_position().
	if owner_node != null and owner_node.has_method("get_global_mouse_position"):
		var mouse_pos = owner_node.get_global_mouse_position()
		var player_pos = owner_node.global_position
		var direction = (mouse_pos - player_pos).normalized()
		return direction if direction.length() > 0 else Vector2.RIGHT
	return Vector2.RIGHT
