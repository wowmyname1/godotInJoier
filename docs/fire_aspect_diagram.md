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