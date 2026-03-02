extends Resource
class_name CameraConfig

# Общая скорость следования камеры (за мышью)
@export var camera_lerp_speed: float = 25.0

# === СГЛАЖИВАНИЕ ОПЕРЕЖЕНИЯ (Ключевой параметр) ===
# 5.0 — очень плавно, как «маслянистое» движение
# 7.0 — золотая середина для плавности
# 10.0+ — уже заметно быстрее
@export var movement_lerp_speed: float = 6.0

# Уменьшаем амплитуду, чтобы рывки были менее заметны
@export var movement_offset_max: float = 40.0

# Порог скорости (чем выше, тем позже включается опережение)
@export var movement_offset_speed_threshold: float = 500.0

# Смещение от мыши
@export var camera_max_offset: float = 120.0
@export var dead_zone_radius: float = 100.0
