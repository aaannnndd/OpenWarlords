
OWL_fnc_updateSectors = compileFinal preprocessFileLineNumbers "Server\updateSectors.sqf";
OWL_fnc_getIncomePayout = compileFinal preprocessFileLineNumbers "Server\getIncomePayout.sqf";
OWL_fnc_updateIncome = compileFinal preprocessFileLineNumbers "Server\updateIncome.sqf";
OWL_fnc_initMapAlterations = compileFinal preprocessFileLineNumbers "Server\initMapAlterations.sqf";
OWL_fnc_updateSpawnPoints = compileFinal preprocessFileLineNumbers "Server\updateSpawnPoints.sqf";

OWL_fnc_handleClientRequest = call compileFinal preprocessFileLineNumbers "Server\handleClientRequest.sqf";
