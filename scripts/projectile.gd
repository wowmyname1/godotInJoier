extends Area2D
class_name Projectile

## Снаряд, летящий в заданном направлении и наносящий урон при столкновении.

@export var speed: float = 400.0
@export var damage: int = 10
@export var direction: Vector2 = Vector2.RIGHT
@export var lifetime: float = 2.0


func _ready() -> void:
	# Запуск анимации
	var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
	if animated_sprite:
		animated_sprite.play("fireball_flee")
	
	# Настройка таймера жизни
	var timer: Timer = get_node_or_null("Timer")
	if timer:
		timer.wait_time = lifetime
		timer.one_shot = true
		timer.timeout.connect(queue_free)
		timer.start()
	else:
		# Если таймера нет, создаем программно
		timer = Timer.new()
		timer.wait_time = lifetime
		timer.one_shot = true
		timer.timeout.connect(queue_free)
		add_child(timer)
		timer.start()

func _physics_process(delta: float) -> void:
	# Движение
	position += direction * speed * delta
	
	# Вращение по направлению полета
	rotation = direction.angle()

func _on_body_entered(body: Node2D) -> void:
	# Игнорируем другие снаряды
	if body is Projectile:
		return
		
	# Проверяем, есть ли у объекта компонент здоровья
	var health: HealthComponent = null
	
	# Пробуем найти HealthComponent в теле
	if body.has_node("HealthComponent"):
		health = body.get_node("HealthComponent") as HealthComponent
	else:
		# Ищем в дочерних узлах
		health = body.find_child("HealthComponent", true, false) as HealthComponent
	
	if health:
		# Наносим урон через компонент
		health.take_damage(damage, self)
	
	# Уничтожаем пулю
	queue_free()
