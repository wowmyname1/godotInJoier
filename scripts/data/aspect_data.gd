class_name AspectData
extends Resource
## Хранит параметры Аспекта (тайминги, правила, условия перехода).

@export_group("Preparation Cycle")
@export var idle_duration: float = 1.0
@export var invocation_duration: float = 0.4
@export var channeling_duration: float = 0.5
@export var after_cast_duration: float = 0.3

@export_group("Charging Windows")
@export var perfect_window_center: float = 0.5
@export var perfect_window_tolerance: float = 0.05
@export var max_charge_duration: float = 1.0

@export_group("Cast Tiers")
@export var low_cast_duration: float = 0.3
@export var natural_cast_duration: float = 0.5
@export var perfect_cast_duration: float = 0.7
@export var miss_cast_duration: float = 0.8

@export_group("Damage Rules")
@export var interrupted_by_damage: bool = true
@export var stagger_resistance: int = 1
@export var reset_combo_on_damage: bool = true

@export_group("Combo & OverCast")
@export var combo_required_for_over_cast: int = 3
@export var over_cast_self_damage: int = 10
@export var over_cast_knockback_force: float = 500.0

@export_group("Aspect Info")
@export var aspect_name: String = "Fire Aspect: Spark"
@export var discipline: String = "Fire Discipline"
@export var transition_conditions: Array = []
