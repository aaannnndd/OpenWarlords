
/******************************************************
***********		Init Clientside Functions	***********
******************************************************/

OWL_fnc_handleServerUpdate = compileFinal preprocessFileLineNumbers "Client\handleServerUpdate.sqf";


waitUntil { !isNull player };
// Do some stuff here that requires the player object

waitUntil { missionNamespace getVariable ["OWL_ServerInitialized", false] };
// Do some stuff here that requires the server to be initialized
