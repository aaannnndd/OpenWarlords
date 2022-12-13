#include "defines.hpp"

// Server
OWL_fnc_updateSectors = call compileFinal preprocessFileLineNumbers "Server\updateSectors.sqf";
OWL_fnc_handleClientRequest = call compileFinal preprocessFileLineNumbers "Server\handleClientRequest.sqf";
OWL_fnc_getIncomePayout = call compileFinal preprocessFileLineNumbers "Server\getIncomePayout.sqf";
OWL_fnc_updateIncome = call compileFinal preprocessFileLineNumbers "Server\updateIncome.sqf";
OWL_fnc_initMapAlterations = call compileFinal preprocessFileLineNumbers "Server\initMapAlterations.sqf";

// Common
OWL_fnc_calculateAttackableSectors = call compileFinal preprocessFileLineNumbers "Common\calculateAttackableSectors.sqf";
OWL_fnc_calculateProtectableSectors = call compileFinal preprocessFileLineNumbers "Common\calculateProtectableSectors.sqf";
OWL_fnc_calculateSectorRelationships = call compileFinal preprocessFileLineNumbers "Common\calculateSectorRelationships.sqf";
OWL_fnc_calculateLinkedSectors = call compileFinal preprocessFileLineNumbers "Common\calculateLinkedSectors.sqf";

// Client
OWL_fnc_handleServerUpdate = call compileFinal preprocessFileLineNumbers "Client\handleServerUpdate.sqf";


if (hasInterface or {isServer}) then {
	call compileFinal preprocessFileLineNumbers "Common\initCommon.sqf";
};
if (isServer) then {
	call compileFinal preprocessFileLineNumbers "Server\initServer.sqf";
};
if (hasInterface) then {
	call compileFinal preprocessFileLineNumbers "Client\initClient.sqf";
};

// :D
[] spawn compileFinal preprocessFileLineNumbers "TEMP.sqf";
