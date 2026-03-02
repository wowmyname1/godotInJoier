extends CharacterBody2D

@export var config: PlayerConfig
@export var mouse_deadzone: float = 5.0

@onready var aspect_manager: Node = $AspectManager

func _input(event: InputEvent) -> void:
	if aspect_manager:
		aspect_manager._input(event)

var cached_forward_dir: Vector2 = Vector2.RIGHT
var last_rotation: float = 0.0

func _physics_process(delta: float) -> void:
	handle_rotation(delta)
	handle_movement(delta)


func handle_rotation(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var direction_to_mouse = mouse_pos - global_position
	
	if direction_to_mouse.length_squared() > mouse_deadzone * mouse_deadzone:
		var target_angle = direction_to_mouse.angle()
		rotation = lerp_angle(rotation, target_angle, config.rotation_speed * delta)
		last_rotation = rotation
	else:
		rotation = lerp_angle(rotation, last_rotation, config.rotation_speed * delta)

func handle_movement(delta: float) -> void:
	var input_forward = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var input_strafe = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	var is_moving = abs(input_forward) > 0.1 or abs(input_strafe) > 0.1
	
	if is_moving:
		var mouse_pos = get_global_mouse_position()
		var direction_to_mouse = mouse_pos - global_position
		
		if direction_to_mouse.length_squared() > mouse_deadzone * mouse_deadzone:
			cached_forward_dir = direction_to_mouse.normalized()
		
		var forward_dir = cached_forward_dir
		var right_dir = forward_dir.rotated(PI / 2)
		
		var desired_direction = (forward_dir * input_forward) + (right_dir * input_strafe)
		
		if desired_direction.length_squared() > 1.0:
			desired_direction = desired_direction.normalized()
		
		var target_velocity = desired_direction * config.move_speed
		
		var speed_dot = velocity.normalized().dot(desired_direction)
		
		if speed_dot < 0.5: 
			velocity = velocity.move_toward(target_velocity, config.turn_acceleration * delta)
		else:
			velocity = velocity.move_toward(target_velocity, config.acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, config.friction * delta)
	
	var current_speed = velocity.length()
	if abs(current_speed - config.move_speed) < 1.0:
		velocity = velocity.normalized() * config.move_speed
	
	move_and_slide()
