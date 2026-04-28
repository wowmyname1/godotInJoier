extends StaticBody2D

## Манекен для тестирования урона. Имеет компонент здоровья и уничтожается при смерти.

@onready var health: HealthComponent = $HealthComponent


func _ready() -> void:
	if health:
		health.died.connect(_on_enemy_died)


func _on_enemy_died() -> void:
	queue_free()
