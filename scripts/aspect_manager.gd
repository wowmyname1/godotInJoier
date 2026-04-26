class_name AspectManager
extends Node
## Управляет состояниями заклинателя и переключает Аспекты.
## Оркестрирует FSM, проверяет Transition Conditions, хранит глобальный прогресс.

# ─────────────────────────────────────────────────────────────────────────────
# ПЕРЕМЕННЫЕ
# ─────────────────────────────────────────────────────────────────────────────

var current_state: CasterState = null
var states: Dictionary = {}
var current_aspect: AspectData = null
var combo_count: int = 0

# ▼─── НОВОЕ: Отслеживание условий перехода ───▼
var transition_conditions: Array = []
var transition_progress: Dictionary = {}

@export var aspect_data: AspectData
@export var debug_label: Label = null

# ─────────────────────────────────────────────────────────────────────────────
# ЖИЗНЕННЫЙ ЦИКЛ
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_initialize_transition_conditions()
	_initialize_states()
	change_state(StateNames.IDLE)

# ─────────────────────────────────────────────────────────────────────────────
# ИНИЦИАЛИЗАЦИЯ СОСТОЯНИЙ
# ─────────────────────────────────────────────────────────────────────────────

func _initialize_states() -> void:
	# Создаём все состояния
	var idle = IdleState.new()
	idle.set_name(StateNames.IDLE)
	
	var invocation = InvocationState.new()
	invocation.set_name("Invocation")
	
	var invocation_failed = InvocationFailedState.new()  # ← НОВОЕ
	invocation_failed.set_name("InvocationFailed")
	
	var channeling = ChannelingState.new()
	channeling.set_name("Channeling")
	
	var charging = ChargingState.new()
	charging.set_name("Charging")
	
	var low_cast = LowCastState.new()
	low_cast.set_name(StateNames.LOW_CAST)
	
	var natural_cast = NaturalCastState.new()
	natural_cast.set_name(StateNames.NATURAL_CAST)
	
	var perfect_cast = PerfectCastState.new()
	perfect_cast.set_name(StateNames.PERFECT_CAST)
	
	var over_cast = OverCastState.new()  # ← НОВОЕ
	over_cast.set_name(StateNames.OVER_CAST)
	
	var after_cast = AfterCastState.new()
	after_cast.set_name("AfterCast")
	
	var miss_cast = MissCastState.new()  # ← НОВОЕ
	miss_cast.set_name("MissCast")
	
	# Регистрируем в словаре
	states[StateNames.IDLE] = idle
	states["Invocation"] = invocation
	states["InvocationFailed"] = invocation_failed  # ← НОВОЕ
	states["Channeling"] = channeling
	states["Charging"] = charging
	states[StateNames.LOW_CAST] = low_cast
	states[StateNames.NATURAL_CAST] = natural_cast
	states[StateNames.PERFECT_CAST] = perfect_cast
	states[StateNames.OVER_CAST] = over_cast  # ← НОВОЕ
	states["AfterCast"] = after_cast
	states["MissCast"] = miss_cast  # ← НОВОЕ
	
	# Инициализируем каждое состояние
	for state in states.values():
		add_child(state)
		state.set_owner_node(self)
		state.aspect_data = aspect_data
		state.state_finished.connect(_on_state_finished)
		state.cast_completed.connect(_on_cast_completed)  # ← НОВОЕ

# ─────────────────────────────────────────────────────────────────────────────
# TRANSITION CONDITIONS (Observer Pattern)
# ─────────────────────────────────────────────────────────────────────────────

func _initialize_transition_conditions() -> void:
	## Копируем условия из ресурса, чтобы не модифицировать исходный
	transition_conditions.clear()
	transition_progress.clear()
	
	if aspect_data != null:
		for condition in aspect_data.transition_conditions:
			var cond_copy = condition.duplicate()
			transition_conditions.append(cond_copy)
			transition_progress[cond_copy.condition_name] = 0
			print("[AspectManager] Loaded transition condition: ", cond_copy.condition_name)

func _on_cast_completed(cast_tier: String) -> void:
	## Вызывается после каждого завершённого каста.
	## Обновляет комбо и проверяет условия перехода.
	
	# Обновляем комбо
	if cast_tier == StateNames.PERFECT_CAST:
		increment_combo()
	else:
		reset_combo()
	
	# Обновляем прогресс условий перехода
	_update_transition_progress(cast_tier)
	
	# Проверяем, выполнено ли какое-либо условие
	_check_transition_conditions()

func _update_transition_progress(cast_tier: String) -> void:
	## Обновляет счётчики в условиях перехода
	for condition in transition_conditions:
		if condition.has_method("on_cast_completed"):
			condition.on_cast_completed(cast_tier)

func _check_transition_conditions() -> void:
	## Проверяет все условия. Если одно выполнено — начинает переход.
	for condition in transition_conditions:
		if condition.check():
			print("[AspectManager] Transition condition met: ", condition.condition_name)
			_initiate_aspect_transition(condition.target_aspect_name)
			return  # Только один переход за раз

func _initiate_aspect_transition(target_aspect_name: String) -> void:
	## Принудительный переход в TransitionState из ЛЮБОГО состояния.
	## Это единственный случай, когда меняем состояние без сигнала.
	
	print("[AspectManager] Initiating transition to: ", target_aspect_name)
	
	if current_state != null:
		current_state._on_exit()
	
	# Создаём состояние перехода
	var transition = TransitionState.new()
	transition.set_name("Transition")
	transition.target_aspect_name = target_aspect_name
	transition.set_owner_node(self)
	
	# Подключаем сигнал завершения перехода
	transition.transition_completed.connect(_on_transition_completed)
	
	add_child(transition)
	current_state = transition
	current_state._on_enter()
	
	print("[AspectManager] Entered TransitionState")

func _on_transition_completed(new_aspect: AspectData) -> void:
	## Завершение перехода — загрузка нового Аспекта.
	
	print("[AspectManager] Transition complete! New aspect: ", new_aspect.aspect_name)
	
	# Очищаем старое состояние перехода
	if current_state != null and current_state.name == "Transition":
		current_state._on_exit()
		current_state.queue_free()
	
	# Обновляем текущий Аспект
	current_aspect = new_aspect
	aspect_data = new_aspect
	
	# Пересоздаём состояния с новыми данными
	_reinitialize_states()
	
	# Сбрасываем условия перехода для нового Аспекта
	transition_conditions.clear()
	_initialize_transition_conditions()
	
	# Начинаем с Idle нового Аспекта
	change_state("Idle")

func _reinitialize_states() -> void:
	## Удаляет старые состояния и создаёт новые с обновлённым AspectData.
	
	# Удаляем старые состояния (кроме Transition, если вдруг остался)
	for state in states.values():
		if is_instance_valid(state):
			state.queue_free()
	states.clear()
	
	# Создаём новые
	_initialize_states()

# ─────────────────────────────────────────────────────────────────────────────
# ОБРАБОТКА СОСТОЯНИЙ
# ─────────────────────────────────────────────────────────────────────────────

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
	## Стандартный переход по сигналу от состояния.
	change_state(next_state_name)

func handle_damage(amount: int) -> void:
	if current_state != null:
		current_state._on_damage(amount)

# ─────────────────────────────────────────────────────────────────────────────
# КОМБО-СИСТЕМА
# ─────────────────────────────────────────────────────────────────────────────

func increment_combo() -> void:
	combo_count += 1
	print("[AspectManager] Combo: ", combo_count)
	
	if aspect_data != null and combo_count >= aspect_data.combo_required_for_over_cast:
		print("[AspectManager] OVER CAST READY!")

func reset_combo() -> void:
	if combo_count > 0:
		combo_count = 0
		print("[AspectManager] Combo reset")

# ─────────────────────────────────────────────────────────────────────────────
# ОТЛАДКА
# ─────────────────────────────────────────────────────────────────────────────

func get_transition_progress() -> Dictionary:
	## Возвращает прогресс всех условий перехода (для UI).
	return transition_progress.duplicate()
