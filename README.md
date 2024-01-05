# _Custom Roles for TTT_ Roles Pack for Jingle Jam 2023
A pack of [Custom Roles for TTT](https://github.com/Custom-Roles-for-TTT/TTT-Custom-Roles) roles created based on the generous donations of our community members in support of [Jingle Jam 2023](https://www.jinglejam.co.uk/).

# Roles

## Elementalist
_Suggested By_: Logan\
The Elementalist is a Traitor role who, instead of regular traitor weapons, gains access to special elemental power-ups in their shop.
\
\
**ConVars**
```cpp
ttt_elementalist_enabled                    0   // Whether or not the Elementalist should spawn
ttt_elementalist_spawn_weight               1   // The weight assigned to spawning the Elementalist
ttt_elementalist_min_players                0   // The minimum number of players required to spawn the Elementalist
ttt_elementalist_allow_effect_upgrades      1   // Whether the upgraded versions of the effects are available for purchase, i.e. Pyromancer+
ttt_elementalist_allow_pyromancer_upgrades  1   // Whether the role can purchase the Pyromancer upgrade
ttt_elementalist_allow_frostbite_upgrades   1   // Whether the role can purchase the Frostbite upgrade
ttt_elementalist_allow_windburn_upgrades    1   // Whether the role can purchase the Windburn upgrade
ttt_elementalist_allow_discharge_upgrades   1   // Whether the role can purchase the Discharge upgrade
ttt_elementalist_allow_midnight_upgrades    1   // Whether the role can purchase the Midnight upgrade
ttt_elementalist_allow_lifesteal_upgrades   1   // Whether the role can purchase the Lifesteal upgrade
ttt_elementalist_frostbite_effect_duration  3   // How long the Frostbite slow & freeze effect lasts
ttt_elementalist_frostbite+_freeze_chance   5   // The percent chance shooting a victim which has been slowed by Frostbite will instead freeze them
ttt_elementalist_pyromancer_burn_duration   3   // How long the Pryomancer effect should burn the victim for, 100 damage would scale for the full length
ttt_elementalist_pyromancer+_explode_chance 5   // The percent chance shooting a victim ignited by Pyromancer will cause them to explode
ttt_elementalist_midnight_dim_duration      3   // How long the Midnight screen dimming effect should last
ttt_elementalist_midnight+_blindness_chance 5   // The percent chance shooting a victim affected by Midnight will instead completely blind them
ttt_elementalist_windburn_push_power        700 // How much push power the windburn effect should apply to victims, scales with damage done
ttt_elementalist_windburn+_launch_chance    5   // The percent chance shooting a victim will launch instead of push them
ttt_elementalist_discharge_punch_power      5   // How much view punch power the discharge effect should apply to victims, scales with damage done
ttt_elementalist_discharge+_input_chance    5   // The percent chance shooting a victim will cause them to apply a random input in additional to the view punch
ttt_elementalist_lifesteal_heal_percentage  60  // What percent of damage done by shooting should be converted into health for the Elementalist
ttt_elementalist_lifesteal+_execute_amount  15  // How much life a victim must reach before Lifesteal+ will execute them
```

# Special Thanks
- [Game icons](https://game-icons.net/) for the role icons