## Константы имен состояний для системы заклинаний
## Используется для предотвращения опечаток и централизованного управления именами состояний

class_name StateNames

# Основные состояния каста
const LOW_CAST := "LowCast"
const PERFECT_CAST := "PerfectCast"
const OVER_CAST := "OverCast"
const NATURAL_CAST := "NaturalCast"

# Состояния ожидания и бездействия
const IDLE := "Idle"
const READY := "Ready"

# Состояния восстановления
const COOLDOWN := "Cooldown"
const RECOVERING := "Recovering"

# Вспомогательные методы для проверки
static func is_cast_state(state_name: String) -> bool:
	return state_name in [LOW_CAST, PERFECT_CAST, OVER_CAST, NATURAL_CAST]

static func is_active_state(state_name: String) -> bool:
	return state_name in [IDLE, READY] or is_cast_state(state_name)
