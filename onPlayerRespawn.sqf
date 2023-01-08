//params ["_newUnit", "_oldUnit", "_respawnType", "_respawnDelay"];
["onPlayerRespawn.sqf fired. Params: " + str _this] call OWL_fnc_log;

OWL_respawnedAtLeastOnce = true;
