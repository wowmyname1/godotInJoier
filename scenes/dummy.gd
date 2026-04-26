extends StaticBody2D

@onready var health: HealthComponent = $HealthComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health.died.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
