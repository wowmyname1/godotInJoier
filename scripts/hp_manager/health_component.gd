class_name HealthComponent extends Node

## Сигналы для уведомления других систем (UI, Звуки, Логика)
signal health_changed(current: int, max: int)
signal died()
signal healed(amount: int)
signal damaged(amount: int)

## Настройки в инспекторе
@export var max_health: int = 100
@export var start_health: int = 100


## Текущее состояние
var current_health: int
var is_dead: bool = false


## Таймер для неуязвимости (опционально)
var _invincibility_timer: Timer

func _ready() -> void:
	current_health = start_health
	# Сообщаем начальное состояние (важно для UI)
	health_changed.emit(current_health, max_health)



## Получить урон
func take_damage(amount: int, damage_source: Node = null) -> void:
	if is_dead or amount <= 0:
		return

	current_health = max(0, current_health - amount)
	damaged.emit(amount)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		die()

## Получить лечение
func heal(amount: int) -> void:
	if is_dead or amount <= 0:
		return

	var old_health = current_health
	current_health = min(max_health, current_health + amount)
	var actual_heal = current_health - old_health
	
	if actual_heal > 0:
		healed.emit(actual_heal)
		health_changed.emit(current_health, max_health)

## Смерть
func die() -> void:
	if is_dead:
		return
	
	is_dead = true
	current_health = 0
	health_changed.emit(current_health, max_health)
	died.emit()
	# Важно: мы НЕ делаем queue_free() здесь. 
	# Родительский узел (Игрок/Враг) должен решить, что делать при смерти.

## Сброс здоровья (для респавна)
func reset_health() -> void:
	is_dead = false
	current_health = start_health
	if _invincibility_timer:
		_invincibility_timer.start()
	health_changed.emit(current_health, max_health)
