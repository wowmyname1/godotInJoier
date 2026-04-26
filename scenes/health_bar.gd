extends ProgressBar

@export var target_health: HealthComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if target_health:
		target_health.health_changed.connect(_on_health_changed)
		# Инициализация значений
		max_value = target_health.max_health
		value = target_health.current_health

func _on_health_changed(current: int, max: int) -> void:
	max_value = max
	# Плавное изменение (опционально)
	var tween = create_tween()
	tween.tween_property(self, "value", current, 0.2)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
