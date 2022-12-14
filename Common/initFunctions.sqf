#include "..\defines.hpp"

// Common functions
OWL_fnc_calculateAttackableSectors = compileFinal preprocessFileLineNumbers "Common\calculateAttackableSectors.sqf";
OWL_fnc_calculateProtectableSectors = compileFinal preprocessFileLineNumbers "Common\calculateProtectableSectors.sqf";
OWL_fnc_calculateSectorRelationships = compileFinal preprocessFileLineNumbers "Common\calculateSectorRelationships.sqf";
OWL_fnc_calculateLinkedSectors = compileFinal preprocessFileLineNumbers "Common\calculateLinkedSectors.sqf";

if (isServer) then {
	// Server functions
	OWL_fnc_updateSectors = compileFinal preprocessFileLineNumbers "Server\updateSectors.sqf";
	OWL_fnc_handleClientRequest = compileFinal preprocessFileLineNumbers "Server\handleClientRequest.sqf";
	OWL_fnc_getIncomePayout = compileFinal preprocessFileLineNumbers "Server\getIncomePayout.sqf";
	OWL_fnc_updateIncome = compileFinal preprocessFileLineNumbers "Server\updateIncome.sqf";
	OWL_fnc_initMapAlterations = compileFinal preprocessFileLineNumbers "Server\initMapAlterations.sqf";
};

if (hasInterface) then {
	// Client functions
	OWL_fnc_handleServerUpdate = compileFinal preprocessFileLineNumbers "Client\handleServerUpdate.sqf";
};
