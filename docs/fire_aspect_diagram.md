stateDiagram-v2
[*] --> fire_aspect : check aspect
state fire_aspect {
    [*] --> idle_state 
    idle_state --> invocation_state : on mouse down
    invocation_state --> invocation_failed : on mouse down
    invocation_failed --> idle_state : on time out hold
    invocation_failed --> invocation_state: on time out
    invocation_state --> channeling_state: on time out
    channeling_state --> nature_cast: on time out
    nature_cast --> after_cast: on time out
    after_cast --> channeling_state: on time out
    after_cast --> miss_cast: on mouse down
    miss_cast--> channeling_state: on time out
    miss_cast--> invocation_failed: on time out hold
    channeling_state--> charging_state: on mouse down
    state fork_state <<fork>>
      charging_state --> fork_state : on release
      fork_state --> low_cast: t1
      fork_state --> perfect_cast: t2
      fork_state --> over_cast: t3
      state join_state <<join>>
      low_cast-->join_state
      over_cast-->join_state
      perfect_cast-->join_state
      join_state--> after_cast: on time out
      
}
[mermaid](https://mermaid.live/edit#pako:eNqNlNtymzAQhl9Fs5cd29MY44Am45vkti_Q0slo0AKqQesRwmnr8bsXi5OtmiRcsfq_f7VaHU6QkkTgUFth8UWJ3IhqeVwn-seXn2y53LFMGXwV9QFTyzhLC0z3rAsT7Uw3xCnRrP0Gs5IlvnZUJ1wNOF0fKRVWke4HOSPNKmpqZJLedG_yKc-aCVWi_NDbY15dzmVVhYwaywoq5btGr5Qb9zvVpoXQGkul81mfjzifFrZpu5uK2t6xXKmOFplFMwdP4mcr8hyVquspud_oUf1k8hv-v2bP7YqfuJ_M5LdT-cX1B5XMvu_t09Ml2O06mXk5uoM_0S6nwRJFjYPjSr7QJb31vbEPM8gBTdbekQFbz2B0HPfQBgPTyb9I6XEBl2BawDB_m2GiBnFMeVe9rusuMI18eMhYe8_PsIDcKAncmgYXUKGpxCUE9zokYAusMAHe_kph9gl0noPQ34mqwWaoyQvgmSjrNmoOcnqgRgS1RPNMjbbAty4D8BP8Bh6E0SqO1kG43QbROozDBfwBHj6sNnEcP8bRJog3URCfF_DXTfl1FT22DEplyXzrnkT3Mp7_AbJ6uWM)