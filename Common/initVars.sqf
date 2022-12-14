#include "..\defines.hpp"

OWL_devMode = true;

// Common vars
OWL_competingSides = [[WEST, EAST], [WEST, RESISTANCE], [EAST, RESISTANCE]] # (["Combatants"] call BIS_fnc_getParamValue);
OWL_defendingSide = [RESISTANCE, EAST, WEST] # (["Combatants"] call BIS_fnc_getParamValue);
// Maybe we should replace this with more generalized OWL_side1Base, OWL_side2Base?
OWL_mainBases = [missionNamespace getVariable format ["OWL_mainBase_%1", OWL_competingSides # 0], 
				 missionNamespace getVariable format ["OWL_mainBase_%1", OWL_competingSides # 1]];

if (isServer) then {
	// Server side vars
	
	OWL_useVanillaIncomeCalculation = (["IncomeCalculation"] call BIS_fnc_getParamValue) == 1;
	OWL_maxPlayersForSide = log 0;
	{
		if (playableSlotsNumber _x > OWL_maxPlayersForSide) then {
			OWL_maxPlayersForSide = playableSlotsNumber _x;
		};
	} forEach OWL_competingSides;
};

if (hasInterface) then {
	// Client side vars
};
