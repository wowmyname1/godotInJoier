class_name AspectManager
extends Node
## Управляет состояниями заклинателя и переключает Аспекты.

var current_state: CasterState = null
var states: Dictionary = {}
var current_aspect: AspectData = null
var combo_count: int = 0

@export var aspect_data: AspectData  # ← ИСПРАВЛЕНО: двоеточие + имя
@export var debug_label: Label = null

func _ready() -> void:
	_initialize_states()
	change_state("Idle")

func _initialize_states() -> void:
	var idle = IdleState.new()
	idle.set_name("Idle")
	
	var invocation = InvocationState.new()
	invocation.set_name("Invocation")
	
	var channeling = ChannelingState.new()
	channeling.set_name("Channeling")
	
	var charging = ChargingState.new()
	charging.set_name("Charging")
	
	var low_cast = LowCastState.new()
	low_cast.set_name("LowCast")
	
	var natural_cast = NaturalCastState.new()
	natural_cast.set_name("NaturalCast")
	
	var perfect_cast = PerfectCastState.new()
	perfect_cast.set_name("PerfectCast")
	
	var after_cast = AfterCastState.new()
	after_cast.set_name("AfterCast")
	
	states["Idle"] = idle
	states["Invocation"] = invocation
	states["Channeling"] = channeling
	states["Charging"] = charging
	states["LowCast"] = low_cast
	states["NaturalCast"] = natural_cast
	states["PerfectCast"] = perfect_cast
	states["AfterCast"] = after_cast
	
	for state in states.values():
		add_child(state)
		state.set_owner_node(self)
		state.aspect_data = aspect_data  # ← Теперь имена совпадают
		state.state_finished.connect(_on_state_finished)

func _process(delta: float) -> void:
	if current_state != null:
		current_state._on_update(delta)
		if debug_label:
			debug_label.text = current_state.name

func _input(event: InputEvent) -> void:
	if current_state != null:
		current_state._on_input(event)

func change_state(state_name: String) -> void:
	if current_state != null:
		current_state._on_exit()
	
	if states.has(state_name):
		current_state = states[state_name]
		current_state._on_enter()
		print("[AspectManager] Changed to: ", state_name)
	else:
		push_error("[AspectManager] State not found: " + state_name)

func _on_state_finished(next_state_name: String) -> void:
	change_state(next_state_name)

func handle_damage(amount: int) -> void:
	if current_state != null:
		current_state._on_damage(amount)

func increment_combo() -> void:
	combo_count += 1
	print("[AspectManager] Combo: ", combo_count)
	
	if aspect_data != null and combo_count >= aspect_data.combo_required_for_over_cast:
		print("[AspectManager] OVER CAST READY!")

func reset_combo() -> void:
	combo_count = 0
	print("[AspectManager] Combo reset")
