//params ["_newUnit", "_oldUnit", "_respawnType", "_respawnDelay"];
["onPlayerRespawn.sqf fired. Params: " + str _this] call OWL_fnc_log;
if (isDedicated) exitWith { ["onPlayerRespawn.sqf fired for dedicated???"] call OWL_fnc_log; };

//OWL_respawnedAtLeastOnce = true;
