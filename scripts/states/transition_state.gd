class_name TransitionState
extends CasterState
## Состояние перехода между Аспектами (эволюция).
## Непрерываемое состояние, которое загружает новый Аспект.
## Используется, когда выполнены Transition Conditions.

signal transition_completed(new_aspect: AspectData)

var target_aspect_name: String
var transition_duration: float = 2.0

func _on_enter() -> void:
	super._on_enter()
	print("[TransitionState] Entered - Evolving to: ", target_aspect_name)

func _on_update(delta: float) -> void:
	super._on_update(delta)
	
	if timer >= transition_duration:
		var new_aspect = _load_target_aspect()
		transition_completed.emit(new_aspect)

func _load_target_aspect() -> AspectData:
	## Загружает ресурс нового Аспекта.
	## Временная реализация — замените на свою логику загрузки.
	
	# Пытаемся загрузить по имени
	var path = "res://resources/%s.tres" % target_aspect_name.to_lower().replace(" ", "_")
	var loaded = ResourceLoader.load(path) as AspectData
	
	if loaded != null:
		print("[TransitionState] Loaded aspect: ", loaded.aspect_name)
		return loaded
	else:
		# Если не нашли — возвращаем текущий (fallback)
		print("[TransitionState] Warning: Could not load aspect '", target_aspect_name, "'")
		print("[TransitionState] Fallback to current aspect")
		return aspect_data

func _on_input(event: InputEvent) -> void:
	# Переход нельзя прервать
	pass

func _on_damage(amount: int) -> void:
	# Переход нельзя прервать уроном
	pass
