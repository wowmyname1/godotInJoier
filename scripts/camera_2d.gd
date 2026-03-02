extends Camera2D

@export var config: CameraConfig
@export var dead_zone_radius: float = 100.0
@export var player: CharacterBody2D

var viewport_center: Vector2 = Vector2(960, 540)
var viewport_size: Vector2 = Vector2(1920, 1080)  # Храним размер
var max_viewport_distance: float = 1.0
var smooth_movement_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	_update_viewport_cache()
	
	if config == null:
		push_error("CameraConfig не назначен!")
		return
	
	if player == null:
		player = get_parent()
		if player == null:
			push_error("Player не найден!")
			return
	
	get_viewport().size_changed.connect(_update_viewport_cache)

func _update_viewport_cache() -> void:
	var size = get_viewport_rect().size
	if size.x > 0 and size.y > 0:
		viewport_size = size
		viewport_center = size * 0.5
		max_viewport_distance = viewport_center.length() - dead_zone_radius
		if max_viewport_distance <= 0:
			max_viewport_distance = 1.0

func _physics_process(delta: float) -> void:
	update_offset(delta)

func update_offset(delta: float) -> void:
	if config == null or player == null:
		return
	
	# === 1. ПОЛУЧЕНИЕ И ОГРАНИЧЕНИЕ МЫШИ ===
	var mouse_pos = get_viewport().get_mouse_position()
	
	# ГЛАВНОЕ ИСПРАВЛЕНИЕ:
	# Принудительно держим мышь в пределах экрана.
	# Даже если курсор ушёл за окно, для камеры он остаётся на границе.
	mouse_pos = mouse_pos.clamp(Vector2.ZERO, viewport_size)
	
	var direction = mouse_pos - viewport_center
	var distance = direction.length()
	
	var mouse_offset = Vector2.ZERO
	if distance >= dead_zone_radius and max_viewport_distance > 0:
		var strength = (distance - dead_zone_radius) / max_viewport_distance
		strength = clamp(strength, 0.0, 1.0)
		mouse_offset = direction.normalized() * config.camera_max_offset * strength
	
	# === 2. СМЕЩЕНИЕ ОТ ДВИЖЕНИЯ ===
	var target_movement_offset = Vector2.ZERO
	if player.velocity.length() > 10:
		var speed_ratio = player.velocity.length() / config.movement_offset_speed_threshold
		speed_ratio = clamp(speed_ratio, 0.0, 1.0)
		var move_dir = player.velocity.normalized()
		target_movement_offset = move_dir * config.movement_offset_max * speed_ratio
	
	smooth_movement_offset = smooth_movement_offset.lerp(target_movement_offset, delta * config.movement_lerp_speed)
	
	# === 3. ОБЪЕДИНЕНИЕ ===
	var target_offset = mouse_offset + smooth_movement_offset
	
	# === 4. СЛЕДОВАНИЕ ===
	var coef = 1.0 - exp(-config.camera_lerp_speed * delta)
	offset = offset + (target_offset - offset) * coef
