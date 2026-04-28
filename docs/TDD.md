# Technical Design Document: Fire Aspect Prototype

## 1. Архитектура проекта
- **Движок:** Godot 4.6.2
- **Язык:** GDScript
- **Паттерны:**
  - **Finite State Machine (FSM):** Для управления состояниями игрока (Aspect States), врагов (AI States) и заклинаний.
  - **Component-based:** Сущности состоят из компонентов (Health, Damageable, Movement, Spellcaster).
  - **Resource-based:** Данные врагов, типы урона и резисты вынесены в ресурсы (`*.tres`).

## 2. Структура сцен
```text
res://
├── scenes/
│   ├── game/
│   │   ├── main.tscn          # Основная сцена игры
│   │   ├── world/
│   │   │   ├── room_start.tscn
│   │   │   ├── corridor.tscn
│   │   │   └── arena.tscn
│   │   ├── entities/
│   │   │   ├── player/
│   │   │   │   ├── player.tscn
│   │   │   │   └── states/    # Состояния аспектов
│   │   │   └── enemies/
│   │   │       ├── crypt.tscn
│   │   │       └── fire_caster.tscn
│   │   └── ui/
│   │       └── hud.tscn       # Интерфейс (полоски здоровья)
├── scripts/
│   ├── components/            # Переиспользуемые компоненты
│   ├── systems/               # Глобальные системы (DamageSystem, GameState)
│   └── resources/             # Классы ресурсов
└── docs/                      # Документация
