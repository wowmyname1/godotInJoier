extends Area2D
class_name Projectile
@export var speed: float = 400.0
@export var damage: int = 10
@export var direction: Vector2 = Vector2.RIGHT
@export var lifetime: float = 2.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Запуск анимации
	if $AnimatedSprite2D:
		$AnimatedSprite2D.play("fireball_flee")
	
	# Настройка таймера жизни (если есть Timer)
	if has_node("Timer"):
		$Timer.wait_time = lifetime
		$Timer.start()
	else:
		# Если таймера нет, создаем программно
		var timer = Timer.new()
		timer.wait_time = lifetime
		timer.one_shot = true
		timer.timeout.connect(queue_free)
		add_child(timer)
		timer.start()

func _physics_process(delta: float) -> void:
	# Движение
	position += direction * speed * delta
	
	# Вращение по направлению полета (для красоты)
	rotation = direction.angle()

func _on_body_entered(body: Node2D) -> void:
	# 1. Игнорируем самого стрелка (чтобы не убить себя при спавне)
	if is_instance_of(body, Projectile):
		return
		
	# 2. Проверяем, есть ли у объекта компонент здоровья
	var health: HealthComponent = body.find_child("HealthComponent")
	
	if health:
		# Наносим урон через компонент
		health.take_damage(damage, self)
		
		# Здесь можно добавить отдачу (knockback), если нужно
		# if body is CharacterBody2D:
		#     body.velocity += direction * 200
	
	# 3. Уничтожаем пулю
	queue_free()
