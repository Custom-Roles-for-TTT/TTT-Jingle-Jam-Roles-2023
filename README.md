# _Custom Roles for TTT_ Roles Pack for Jingle Jam 2023
A pack of [Custom Roles for TTT](https://github.com/Custom-Roles-for-TTT/TTT-Custom-Roles) roles created based on the generous donations of our community members in support of [Jingle Jam 2023](https://www.jinglejam.co.uk/).

# Roles

## Admin
_Suggested By_: Noxx\
The Admin is a detective role who slowly gains power over time which can be spent to run admin commands.
\
\
**ConVars**
```cpp
ttt_admin_enabled             0   // Whether or not the admin should spawn
ttt_admin_spawn_weight        1   // The weight assigned to spawning the admin
ttt_admin_min_players         0   // The minimum number of players required to spawn the admin
ttt_admin_starting_health     100 // The amount of health an admin starts with
ttt_admin_max_health          100 // The maximum amount of health an admin can have
ttt_admin_power_rate          1.5 // How often (in seconds) the Admin gains power
ttt_admin_starting_power      20  // How much power the Admin should spawn with
ttt_admin_slap_cost           10  // How much power the slap command costs. Set to 0 to disable
ttt_admin_bring_cost          15  // How much power the bring command costs. Set to 0 to disable
ttt_admin_goto_cost           15  // How much power the goto command costs. Set to 0 to disable
ttt_admin_send_cost           20  // How much power the send command costs. Set to 0 to disable
ttt_admin_jail_cost           5   // How much power the jail command costs per second. Set to 0 to disable
ttt_admin_ignite_cost         10  // How much power the ignite command costs per second. Set to 0 to disable
ttt_admin_blind_cost          10  // How much power the blind command costs per second. Set to 0 to disable
ttt_admin_freeze_cost         10  // How much power the freeze command costs per second. Set to 0 to disable
ttt_admin_ragdoll_cost        10  // How much power the ragdoll command costs per second. Set to 0 to disable
ttt_admin_strip_cost          60  // How much power the strip command costs. Set to 0 to disable
ttt_admin_respawn_cost        70  // How much power the respawn command costs. Set to 0 to disable
ttt_admin_slay_cost           80  // How much power the slay command costs. Set to 0 to disable
ttt_admin_kick_cost           100 // How much power the kick command costs. Set to 0 to disable
ttt_admin_punish_cost         50  // How much power the punish command costs. Set to 0 to disable. Requires Karma Punishments mod
ttt_admin_credits_starting    1   // The number of credits an admin should start with
ttt_admin_shop_sync           0   // Whether an admin should have all weapons that vanilla detectives have in their weapon shop
ttt_admin_shop_random_percent 0   // The percent chance that a weapon in the shop will be not be shown for the admin
ttt_admin_shop_random_enabled 0   // Whether role shop randomization is enabled for the admin
```

## Elementalist
_Suggested By_: Logan\
The Elementalist is a traitor role who, instead of regular traitor weapons, gains access to special elemental power-ups in their shop.
\
\
**ConVars**
```cpp
ttt_elementalist_enabled                    0   // Whether or not the elementalist should spawn
ttt_elementalist_spawn_weight               1   // The weight assigned to spawning the elementalist
ttt_elementalist_min_players                0   // The minimum number of players required to spawn the elementalist
ttt_elementalist_starting_health            100 // The amount of health an elementalist starts with
ttt_elementalist_max_health                 100 // The maximum amount of health an elementalist can have
ttt_elementalist_allow_effect_upgrades      1   // Whether the upgraded versions of the effects are available for purchase, i.e. pyromancer+
ttt_elementalist_allow_pyromancer_upgrades  1   // Whether the role can purchase the pyromancer upgrade
ttt_elementalist_allow_frostbite_upgrades   1   // Whether the role can purchase the frostbite upgrade
ttt_elementalist_allow_windburn_upgrades    1   // Whether the role can purchase the windburn upgrade
ttt_elementalist_allow_discharge_upgrades   1   // Whether the role can purchase the discharge upgrade
ttt_elementalist_allow_midnight_upgrades    1   // Whether the role can purchase the midnight upgrade
ttt_elementalist_allow_lifesteal_upgrades   1   // Whether the role can purchase the lifesteal upgrade
ttt_elementalist_frostbite_effect_duration  3   // How long the Frostbite slow & freeze effect lasts
ttt_elementalist_frostbite+_freeze_chance   5   // The percent chance shooting a victim which has been slowed by frostbite will instead freeze them
ttt_elementalist_pyromancer_burn_duration   3   // How long the pyromancer effect should burn the victim for, 100 damage would scale for the full length
ttt_elementalist_pyromancer+_explode_chance 5   // The percent chance shooting a victim ignited by pyromancer will cause them to explode
ttt_elementalist_midnight_dim_duration      3   // How long the midnight screen dimming effect should last
ttt_elementalist_midnight+_blindness_chance 5   // The percent chance shooting a victim affected by midnight will instead completely blind them
ttt_elementalist_windburn_push_power        700 // How much push power the windburn effect should apply to victims, scales with damage done
ttt_elementalist_windburn+_launch_chance    5   // The percent chance shooting a victim will launch instead of push them
ttt_elementalist_discharge_punch_power      5   // How much view punch power the discharge effect should apply to victims, scales with damage done
ttt_elementalist_discharge+_input_chance    5   // The percent chance shooting a victim will cause them to apply a random input in additional to the view punch
ttt_elementalist_lifesteal_heal_percentage  60  // What percent of damage done by shooting should be converted into health for the elementalist
ttt_elementalist_lifesteal+_execute_amount  15  // How much life a victim must reach before lifesteal+ will execute them
ttt_elementalist_credits_starting           1   // The number of credits an elementalist should start with
ttt_elementalist_shop_sync                  0   // Whether elementalists should have all weapons that vanilla traitors have in their weapon shop
ttt_elementalist_shop_random_percent        0   // The percent chance that a weapon in the shop will be not be shown for elementalists
ttt_elementalist_shop_random_enabled        0   // Whether role shop randomization is enabled for elementalists
```

## Ghost Whisperer
_Suggested By_: Spaaz\
The Ghost Whisperer is an innocent role who spawns with a ghosting device that can be used to grant a dead player the ability to talk using in game chat.
\
\
**ConVars**
```cpp
ttt_ghostwhisperer_enabled          0   // Whether or not the Ghost Whisperer should spawn
ttt_ghostwhisperer_spawn_weight     1   // The weight assigned to spawning the Ghost Whisperer
ttt_ghostwhisperer_min_players      0   // The minimum number of players required to spawn the Ghost Whisperer
ttt_ghostwhisperer_starting_health  100 // The amount of health a Ghost Whisperer starts with
ttt_ghostwhisperer_max_health       100 // The maximum amount of health a Ghost Whisperer can have
ttt_ghostwhisperer_ghosting_time    8   // The amount of time (in seconds) the Ghost Whisperer's ghosting device takes to use
```

## Physician
_Suggested By_: Logan\
The Physician is a detective role who spawns with a Health Tracker. The Physician can use their custom weapon to place trackers on terrorists to monitor their health from the scoreboard.
An upgrade exclusive to them is available in their shop which upgrades the range and quality of tracking.
\
\
**ConVars**
```cpp
ttt_physician_enabled               0   // Whether or not the physician should spawn
ttt_physician_spawn_weight          1   // The weight assigned to spawning the physician
ttt_physician_min_players           0   // The minimum number of players required to spawn the physician
ttt_physician_starting_health       100 // The amount of health a physician starts with
ttt_physician_max_health            100 // The maximum amount of health a physician can have
ttt_physician_tracker_range_default 200 // Default range of the physician's tracker device
ttt_physician_tracker_range_boosted 400 // Boosted range of the physician's tracker device after the upgrade has been purchased
ttt_physician_credits_starting      1   // The number of credits a physician should start with
ttt_physician_shop_sync             0   // Whether a physician should have all weapons that vanilla detectives have in their weapon shop
ttt_physician_shop_random_percent   0   // The percent chance that a weapon in the shop will be not be shown for the physician
ttt_physician_shop_random_enabled   0   // Whether role shop randomization is enabled for the physician
```

## Renegade
_Suggested By_: Corvatile\
The Renegade is an independent role that wins by being the last player standing. The Renegade knows who the traitors are and the traitors know who the Renegade is.
\
\
**ConVars**
```cpp
ttt_renegade_enabled           0   // Whether or not the renegade should spawn
ttt_renegade_spawn_weight      1   // The weight assigned to spawning the renegade
ttt_renegade_min_players       0   // The minimum number of players required to spawn the renegade
ttt_renegade_starting_health   100 // The amount of health a renegade starts with
ttt_renegade_max_health        100 // The maximum amount of health a renegade can have
ttt_renegade_can_see_jesters   1   // Whether jesters are revealed (via head icons, color/icon on the scoreboard, etc.) to the renegade
ttt_renegade_update_scoreboard 1   // Whether the renegade shows dead players as missing in action
ttt_renegade_warn_all          0   // Whether to warn all players there is a renegade in the round. If disabled, only traitors are warned
ttt_renegade_show_glitch       0   // Whether to allow the renegade to see the glitch. They will show as an unknown traitor
ttt_renegade_shop_mode         0   // What additional items are available to the renegade in the shop (See the CR4TTT shop convars documentation for possible values)
ttt_renegade_can_see_jesters   1   // Whether jesters are revealed (via head icons, color/icon on the scoreboard, etc.) to the renegade
ttt_renegade_update_scoreboard 1   // Whether the renegade shows dead players as missing in action
```

## Soulbound
_Suggested By_: Spaaz\
The Soulbound is a traitor role who is created by the Soulmage. The Soulbound can use special abilities while they are spectating to help fellow traitors.
\
\
**ConVars**
```cpp
ttt_soulbound_max_abilities             3   // The maximum number of abilities the Soulbound can buy. (Set to 0 to disable abilities)
ttt_soulbound_box_enabled               1   // Whether the place box ability is enabled or not
ttt_soulbound_box_uses                  10  // How many uses should of the place box ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_box_cooldown              0   // How long should the Soulbound have to wait between uses of the place box ability
ttt_soulbound_confetti_enabled          1   // Whether the confetti ability is enabled or not
ttt_soulbound_confetti_uses             3   // How many uses should of the confetti ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_confetti_cooldown         3   // How long should the Soulbound have to wait between uses of the confetti ability
ttt_soulbound_decoy_enabled             1   // Whether the place decoy ability is enabled or not
ttt_soulbound_decoy_uses                5   // How many uses should of the place decoy ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_decoy_cooldown            0   // How long should the Soulbound have to wait between uses of the place decoy ability
ttt_soulbound_discombob_enabled         1   // Whether the discombobulator ability is enabled or not
ttt_soulbound_discombob_uses            2   // How many uses should of the discombobulator ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_discombob_cooldown        1   // How long should the Soulbound have to wait between uses of the discombobulator ability
ttt_soulbound_discombob_fuse_time       5   // How long the fuse for the Soulbound's discombobulator should be
ttt_soulbound_dropweapon_enabled        1   // Whether the drop weapon ability is enabled or not
ttt_soulbound_dropweapon_uses           3   // How many uses should of the drop weapon ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_dropweapon_cooldown       10  // How long should the Soulbound have to wait between uses of the drop weapon ability
ttt_soulbound_explosivebarrel_enabled   1   // Whether the place explosive barrel ability is enabled or not
ttt_soulbound_explosivebarrel_uses      2   // How many uses should of the place explosive barrel ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_explosivebarrel_cooldown  0   // How long should the Soulbound have to wait between uses of the place explosive barrel ability
ttt_soulbound_fakebody_enabled          1   // Whether the place fake body ability is enabled or not
ttt_soulbound_fakebody_uses             1   // How many uses should of the place fake body ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_fakebody_cooldown         0   // How long should the Soulbound have to wait between uses of the place fake body ability
ttt_soulbound_fakec4_enabled            1   // Whether the place fake C4 ability is enabled or not
ttt_soulbound_fakec4_uses               1   // How many uses should of the place fake C4 ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_fakec4_cooldown           0   // How long should the Soulbound have to wait between uses of the place fake C4 ability
ttt_soulbound_fakec4_fuse               60  // How long the fuse for the Soulbound's fake C4 should be
ttt_soulbound_gunshots_enabled          1   // Whether the gunshots ability is enabled or not
ttt_soulbound_gunshots_uses             10  // How many uses should of the gunshots grenade ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_gunshots_cooldown         1   // How long should the Soulbound have to wait between uses of the gunshots grenade ability
ttt_soulbound_headcrab_enabled          1   // Whether the summon headcrab ability is enabled or not
ttt_soulbound_headcrab_uses             5   // How many uses should of the summon headcrab ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_headcrab_cooldown         0   // How long should the Soulbound have to wait between uses of the summon headcrab ability
ttt_soulbound_headcrab_health           10  // How much health headcrabs spawned by the Soulbound should have
ttt_soulbound_heal_enabled              1   // Whether the healing presence ability is enabled or not
ttt_soulbound_heal_rate                 0.5 // How often the Soulbound's healing presence ability should heal their target
ttt_soulbound_incendiary_enabled        1   // Whether the incendiary grenade ability is enabled or not
ttt_soulbound_incendiary_uses           2   // How many uses should of the incendiary grenade ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_incendiary_cooldown       1   // How long should the Soulbound have to wait between uses of the incendiary grenade ability
ttt_soulbound_incendiary_fuse_time      5   // How long the fuse for the Soulbound's incendiary grenade should be
ttt_soulbound_poisonheadcrab_enabled    1   // Whether the summon poison headcrab ability is enabled or not
ttt_soulbound_poisonheadcrab_uses       2   // How many uses should of the summon poison headcrab ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_poisonheadcrab_cooldown   0   // How long should the Soulbound have to wait between uses of the summon poison headcrab ability
ttt_soulbound_poisonheadcrab_health     35  // How much health poison headcrabs spawned by the Soulbound should have
ttt_soulbound_poltergeist_enabled       1   // Whether the poltergeist ability is enabled or not
ttt_soulbound_poltergeist_uses          3   // How many uses should of the poltergeist ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_poltergeist_cooldown      0   // How long should the Soulbound have to wait between uses of the poltergeist ability
ttt_soulbound_possession_enabled        1   // Whether the ultra prop possession ability is enabled or not
ttt_soulbound_reveal_enabled            1   // Whether the revealing presence ability is enabled or not
ttt_soulbound_smoke_enabled             1   // Whether the instant smoke ability is enabled or not
ttt_soulbound_smoke_uses                3   // How many uses should of the smoke grenade ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_smoke_cooldown            1   // How long should the Soulbound have to wait between uses of the smoke grenade ability
ttt_soulbound_smoke_linger_time         30  // How long the fuse for the Soulbound's instant smoke should linger for
ttt_soulbound_swapinventory_enabled     1   // Whether the swap inventory ability is enabled or not
ttt_soulbound_swapinventory_uses        1   // How many uses should of the swap inventory ability should the Soulbound get. (Set to 0 for unlimited uses)
ttt_soulbound_swapinventory_cooldown    0   // How long should the Soulbound have to wait between uses of the swap inventory ability
ttt_soulbound_packapunch_enabled        1   // Whether the Pack-a-Punch ability is enabled or not. Requires Pack-a-Punch mod
ttt_soulbound_packapunch_uses           1   // How many uses should of the Pack-a-Punch ability should the Soulbound get. Requires Pack-a-Punch mod. (Set to 0 for unlimited uses)
ttt_soulbound_packapunch_cooldown       5   // How long should the Soulbound have to wait between uses of the Pack-a-Punch ability. Requires Pack-a-Punch mod
```

## Soulmage
_Suggested By_: Spaaz\
The Soulmage is a traitor role who spawns with a soulbinding device that can be used to convert a dead player into a Soulbound.
\
\
**ConVars**
```cpp
ttt_soulmage_enabled                0   // Whether or not the Soulmage should spawn
ttt_soulmage_spawn_weight           1   // The weight assigned to spawning the Soulmage
ttt_soulmage_min_players            0   // The minimum number of players required to spawn the Soulmage
ttt_soulmage_starting_health        100 // The amount of health a Soulmage starts with
ttt_soulmage_max_health             100 // The maximum amount of health a Soulmage can have
ttt_soulmage_ghosting_time          8   // The amount of time (in seconds) the Soulmage's soulbinding device takes to use
ttt_soulmage_credits_starting       0   // The number of credits a Soulmage should start with
ttt_soulmage_shop_sync              0   // Whether Soulmages should have all weapons that vanilla traitors have in their weapon shop
ttt_soulmage_shop_random_percent    0   // The percent chance that a weapon in the shop will be not be shown for Soulmages
ttt_soulmage_shop_random_enabled    0   // Whether role shop randomization is enabled for Soulmages
```

# Special Thanks
- [Game icons](https://game-icons.net/) for the role icons