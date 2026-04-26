@tool
extends Control
## Визуальный эффект частиц с интерактивным взаимодействием курсора.
## Частицы соединяются линиями при близком расположении и реагируют на движение мыши.

# ─────────────────────────────────────────────────────────────────────────────
# КОНСТАНТЫ
# ─────────────────────────────────────────────────────────────────────────────

const DEFAULT_POINT_COLOR := Color.RED
const DEFAULT_LINE_COLOR := Color.WHITE
const TAU := TAU  # 2 * PI

# ─────────────────────────────────────────────────────────────────────────────
# ЭКСПОРТИРУЕМЫЕ ПЕРЕМЕННЫЕ
# ─────────────────────────────────────────────────────────────────────────────

@export var max_points: int = 60
## Максимальное количество частиц на экране.

@export var fade_time: float = 2.0
## Время затухания частиц (в секундах).

@export var max_line_length: float = 160.0
## Максимальное расстояние для соединения частиц линиями.

@export var interact_intensity: float = 3000.0
## Сила взаимодействия частиц с курсором мыши.

@export var min_radius: float = 0.5
## Минимальный радиус частицы.

@export var max_radius: float = 3.0
## Максимальный радиус частицы.

@export var min_velocity: float = 20.0
## Минимальная скорость частицы.

@export var max_velocity: float = 60.0
## Максимальная скорость частицы.

@export var point_color: Color = DEFAULT_POINT_COLOR
## Цвет отрисовки частиц.

@export var line_color: Color = DEFAULT_LINE_COLOR
## Цвет отрисовки соединительных линий.

# ─────────────────────────────────────────────────────────────────────────────
# ВНУТРЕННИЕ КЛАССЫ
# ─────────────────────────────────────────────────────────────────────────────

## Класс представляющий отдельную частицу.
class Particle:
	var position: Vector2      ## Позиция частицы в локальных координатах.
	var velocity: Vector2      ## Базовая скорость движения.
	var radius: float          ## Радиус отрисовки.
	var life: float            ## Текущее время жизни (0.0 - fade_time).
	var interaction_force: Vector2 = Vector2.ZERO  ## Сила взаимодействия с курсором.

# ─────────────────────────────────────────────────────────────────────────────
# ПЕРЕМЕННЫЕ
# ─────────────────────────────────────────────────────────────────────────────

var particles: Array[Particle] = []
## Массив всех активных частиц.

var mouse_position: Vector2 = Vector2.ZERO
## Последняя известная позиция курсора мыши.

# ─────────────────────────────────────────────────────────────────────────────
# ЖИЗНЕННЫЙ ЦИКЛ
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_initialize_particles()


func _physics_process(delta: float) -> void:
	_update_particles(delta)
	queue_redraw()

# ─────────────────────────────────────────────────────────────────────────────
# ИНИЦИАЛИЗАЦИЯ
# ─────────────────────────────────────────────────────────────────────────────

func _initialize_particles() -> void:
	"""Создаёт и инициализирует все частицы."""
	particles.clear()
	for _i in range(max_points):
		particles.append(_create_particle())


func _create_particle() -> Particle:
	"""Создаёт новую частицу со случайными параметрами."""
	var particle = Particle.new()
	_reset_particle(particle)
	return particle


func _reset_particle(particle: Particle) -> Particle:
	"""Сбрасывает параметры частицы и размещает её в случайной позиции."""
	var rect: Rect2 = get_rect()
	
	particle.position = Vector2(
		randf() * rect.size.x,
		randf() * rect.size.y
	)
	particle.velocity = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(min_velocity, max_velocity)
	particle.radius = randf_range(min_radius, max_radius)
	particle.life = 0.0
	particle.interaction_force = Vector2.ZERO
	
	return particle

# ─────────────────────────────────────────────────────────────────────────────
# ОБНОВЛЕНИЕ ЧАСТИЦ
# ─────────────────────────────────────────────────────────────────────────────

func _update_particles(delta: float) -> void:
	"""Обновляет состояние всех частиц."""
	mouse_position = get_local_mouse_position()
	
	for particle in particles:
		_update_particle(particle, delta)
	
	# Первая частица следует за курсором
	if not particles.is_empty():
		particles[0].position = mouse_position


func _update_particle(particle: Particle, delta: float) -> void:
	"""Обновляет состояние отдельной частицы."""
	var rect: Rect2 = get_rect()
	
	if not rect.has_point(particle.position):
		# Частица вне экрана - уменьшаем жизнь
		particle.life -= delta
		if particle.life < 0.0:
			_reset_particle(particle)
	else:
		# Частица на экране - увеличиваем жизнь до максимума
		particle.life = min(particle.life + delta, fade_time)
	
	# Применяем взаимодействие с курсором только к не-первой частице
	if particle != particles[0]:
		_update_interaction_force(particle)
	
	# Обновляем позицию
	particle.position += (particle.velocity + particle.interaction_force) * delta


func _update_interaction_force(particle: Particle) -> void:
	"""Вычисляет силу взаимодействия частицы с курсором мыши."""
	var distance: float = particle.position.distance_to(mouse_position)
	
	if distance < max_line_length and distance > 0.01:
		# Сила обратно пропорциональна расстоянию
		particle.interaction_force = (particle.position - mouse_position).normalized() * (1.0 / distance) * interact_intensity
	else:
		particle.interaction_force = Vector2.ZERO

# ─────────────────────────────────────────────────────────────────────────────
# ОТРИСОВКА
# ─────────────────────────────────────────────────────────────────────────────

func _draw() -> void:
	"""Отрисовывает все частицы и соединения между ними."""
	for particle in particles:
		_draw_particle(particle)
		_draw_connections(particle)


func _draw_particle(particle: Particle) -> void:
	"""Отрисовывает отдельную частицу."""
	var color: Color = point_color
	color.a = particle.life / fade_time
	draw_circle(particle.position, particle.radius, color)


func _draw_connections(particle_a: Particle) -> void:
	"""Отрисовывает линии между близкими частицами."""
	var particle_b: Particle
	var distance: float
	var line_alpha: float
	var line_width: float
	
	# Проверяем только пары с индексом больше текущего (избегаем дублирования)
	for other_particle in particles:
		if particle_a == other_particle or particles.find(particle_a) >= particles.find(other_particle):
			continue
		
		particle_b = other_particle
		distance = particle_a.position.distance_to(particle_b.position)
		
		if distance < max_line_length:
			line_alpha = (1.0 - distance / max_line_length) * min(particle_a.life, particle_b.life) / fade_time
			line_width = 2.0 * (1.0 - distance / max_line_length)
			
			var color: Color = line_color
			color.a = line_alpha
			draw_line(particle_a.position, particle_b.position, color, line_width)
