class_name ChargingState
extends CasterState
## Накопление силы. Игрок удерживает кнопку.
## При отпускании определяется уровень каста по таймингу.
## Fork point: LowCast / PerfectCast / OverCast

var charge_timer: float = 0.0

func _on_enter() -> void:
	super._on_enter()
	charge_timer = 0.0
	print("[ChargingState] Entered - Hold for perfect timing!")
	
	# Отладка: проверяем aspect_data
	if aspect_data != null:
		print("[ChargingState] aspect_data loaded!")
		print("  - perfect_window_center: ", aspect_data.perfect_window_center)
		print("  - perfect_window_tolerance: ", aspect_data.perfect_window_tolerance)
		print("  - max_charge_duration: ", aspect_data.max_charge_duration)
	else:
		print("[ChargingState] ⚠️ WARNING: aspect_data is NULL!")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	charge_timer += delta

func _on_input(event: InputEvent) -> void:
	if event.is_action_released("cast"):
		print("[ChargingState] Released - Charge time: ", charge_timer)
		
		var cast_tier = _determine_cast_tier(charge_timer)
		state_finished.emit(cast_tier)
		print("[ChargingState] Result: ", cast_tier)

func _determine_cast_tier(charge_time: float) -> String:
	print("[ChargingState] _determine_cast_tier() called!")  # ← ЭТО ДОЛЖНО БЫТЬ В КОНСОЛИ!
	
	if aspect_data == null:
		print("[ChargingState] ⚠️ aspect_data is NULL! Returning LowCast")
		return "LowCast"
	
	var window_min = aspect_data.perfect_window_center - aspect_data.perfect_window_tolerance
	var window_max = aspect_data.perfect_window_center + aspect_data.perfect_window_tolerance
	
	print("[ChargingState] Checking timing...")
	print("  - charge_time: ", charge_time)
	print("  - window_min: ", window_min)
	print("  - window_max: ", window_max)
	print("  - max_charge_duration: ", aspect_data.max_charge_duration)
	
	# Перезаряд (слишком долго)
	# Слишком рано (меньше нормы)
	if charge_time < window_min:
		print("  → LowCast (too early)")
		return "LowCast"

# Идеальное окно (норма)
	elif charge_time <= window_max:
		print("  → PerfectCast (in window!)")
		return "PerfectCast"

# Слишком поздно (больше нормы)
# Сюда попадает всё, что > window_max (включая превышение max_charge_duration)
	else:
		print("  → OverCast (too late/long)")
		return "OverCast"

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		if aspect_data.stagger_resistance <= 0:
			state_finished.emit("MissCast")
			if owner_node != null and owner_node.has_method("reset_combo"):
				owner_node.reset_combo()
