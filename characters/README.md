# Characters

Every fighter is built from three pieces that share common base classes:

| Piece | Base class | File |
|---|---|---|
| The character node (physics, stats, move set) | `Fighter` | `characters/fighter.gd` |
| The state machine (STAND, DASH, ledge, hitstun, ...) | `FighterStateMachine` | `characters/fighter_state_machine.gd` |
| The scene (sprite, animations, hurtbox, ray casts, a `State` child) | | `characters/<name>/<name>.tscn` |

`fox/` and `mario/` are the reference examples.

## Configurable stats

Anything that makes characters feel different is an exported property on
`Fighter`, so you can change it in the Godot Inspector on the character's root
node without touching code (the scene stores only the values that differ from
the defaults):

- **Ground movement:** `walk_speed`, `dash_speed`, `run_speed`, `traction`,
  `roll_distance`
- **Jumps:** `jump_force`, `max_jump_force`, `double_jump_force`, `air_jumps`
- **Air movement:** `gravity`, `max_air_speed`, `air_accel`, `fall_speed`,
  `falling_speed`, `max_fall_speed`, `air_dodge_speed`, `up_b_launch_speed`
- **Stats:** `weight`, `stocks`
- **Projectile:** `projectile_scene`

## Adding a character

1. Duplicate an existing character folder and scene; rename and replace the
   sprites and animations.
2. Make `<name>.gd` start with `extends Fighter` and delete the moves you
   have not built yet. Any move you do not override ends immediately.
3. Make `<name>_state_machine.gd` start with `extends FighterStateMachine`
   and set `animations` in `_init()`: a dictionary of state name to animation
   name. An empty string keeps the current animation; a state left out of the
   map is not announced at all.
4. Point the scene's root script at `<name>.gd` and its `State` child's script
   at the state machine.
5. Register the character in `ui/character_select/characterselect.gd` and
   `stages/test_stage.gd`.

## Where a character can differ

Override these only when the default does not fit:

| Hook | In | Purpose |
|---|---|---|
| `NAIR()`, `FAIR()`, `GRAB()`, `UP_SPECIAL()`, ... | `Fighter` | The move set. Called every frame during the move (`frame` counts up); return `true` when it ends. |
| `_projectile_spawn_position(point)` | `Fighter` | Where `create_projectile()` puts the projectile. |
| `_on_turn(dir)` | `Fighter` | Mirror extra nodes when the character turns around. |
| `_physics_extra()` | `Fighter` | Per-frame work such as ticking a custom cooldown. |
| `_state_forward_smash()`, `_state_dash_attack()`, `_state_dair()`, `_state_up_special()`, ... | `FighterStateMachine` | Movement and transitions while in that state. Return a state to switch to, or `null` to stay. |
| `_before_actions()` | `FighterStateMachine` | Runs every frame before input is handled. |
| `_ledge_blocked_states()` | `FighterStateMachine` | States in which grabbing a ledge is not allowed. |

## Checking you did not break anything

`tests/run_regression.sh <out_dir> <godot>` plays Fox and Mario against each
other with seeded random input and records a per-frame trace. Run it before and
after a change and `diff -r` the two folders: any gameplay change shows up as a
difference. See `tests/trace_runner.gd`.
