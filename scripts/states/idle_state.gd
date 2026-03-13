class_name IdleState
extends CasterState
## IdleState — исходное состояние. Ничего не происходит.
## Переход только по нажатию кнопки мыши (согласно Mermaid-диаграмме).

func _on_enter() -> void:
	super._on_enter()
	print("[IdleState] Entered - Waiting for input...")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	# НЕТ авто-перехода по таймеру! Ждём ввода игрока.

func _on_input(event: InputEvent) -> void:
	# Переход в Invocation только по нажатию
	if event.is_action_pressed("cast"):
		state_finished.emit("Invocation")
		print("[IdleState] Mouse down → Invocation")
