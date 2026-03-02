extends Resource
class_name PlayerConfig

@export var move_speed: float = 500.0

# Плавный разгон по прямой
@export var acceleration: float = 12000.0 

# Ускорение при повороте/развороте (должно быть высоким!)
# Позволяет мгновенно менять направление без остановки
@export var turn_acceleration: float = 50000.0 

# Торможение
@export var friction: float = 15000.0

@export var rotation_speed: float = 15.0
