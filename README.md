# _Custom Roles for TTT_ Roles Pack for Jingle Jam 2023
A pack of [Custom Roles for TTT](https://github.com/Custom-Roles-for-TTT/TTT-Custom-Roles) roles created based on the generous donations of our community members in support of [Jingle Jam 2023](https://www.jinglejam.co.uk/).

# Roles

## Physician
_Suggested By_: Logan\
The Physician is a Detective role who spawns with a Health Tracker. The Physician can use their custom weapon to place trackers on terrorists to monitor their health from the scoreboard.
An upgrade exclusive to them is available in their shop which upgrades the range and quality of tracking.
\
\
**ConVars**
```cpp
ttt_physician_enabled                       0   // Whether or not the physician should spawn
ttt_physician_spawn_weight                  1   // The weight assigned to spawning the physician
ttt_physician_min_players                   0   // The minimum number of players required to spawn the physician
ttt_physician_tracker_range_default         200 // Default range of the physician's tracker device
ttt_physician_tracker_range_boosted         400 // Boosted range of the physician's tracker device after the upgrade has been purchased
```

## Renegade
_Suggested By_: Corvatile\
The Renegade is an independent role that wins by being the last player standing. The Renegade knows who the traitors are and the traitors know who the Renegade is.
\
\
**ConVars**
```cpp
ttt_renegade_enabled                0   // Whether or not the renegade should spawn
ttt_renegade_spawn_weight           1   // The weight assigned to spawning the renegade
ttt_renegade_min_players            0   // The minimum number of players required to spawn the renegade
ttt_renegade_can_see_jesters        1   // Whether jesters are revealed (via head icons, color/icon on the scoreboard, etc.) to the renegade
ttt_renegade_update_scoreboard      1   // Whether the renegade shows dead players as missing in action
ttt_renegade_warn_all               0   // Whether to warn all players there is a renegade in the round. If disabled, only traitors are warned
ttt_renegade_show_glitch            0   // Whether to allow the renegade to see the glitch. They will show as an unknown traitor
```

# Special Thanks
- [Game icons](https://game-icons.net/) for the role icons