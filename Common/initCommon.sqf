
/******************************************************
***********		Init Common Functions		***********
******************************************************/

OWL_fnc_calculateAttackableSectors = compileFinal preprocessFileLineNumbers "Common\calculateAttackableSectors.sqf";
OWL_fnc_calculateProtectableSectors = compileFinal preprocessFileLineNumbers "Common\calculateProtectableSectors.sqf";
OWL_fnc_calculateSectorRelationships = compileFinal preprocessFileLineNumbers "Common\calculateSectorRelationships.sqf";
OWL_fnc_calculateLinkedSectors = compileFinal preprocessFileLineNumbers "Common\calculateLinkedSectors.sqf";

OWL_fnc_log = {
	if (OWL_devMode && hasInterface) then {
		systemChat _this;
	};
	diag_log _this;
};


/******************************************************
***********		Init Common Globals			***********
******************************************************/

OWL_devMode = true;
OWL_competingSides = [[WEST, EAST], [WEST, RESISTANCE], [EAST, RESISTANCE]] # (["Combatants"] call BIS_fnc_getParamValue);
OWL_defendingSide = [RESISTANCE, EAST, WEST] # (["Combatants"] call BIS_fnc_getParamValue);
// Maybe we should replace this with something more generalized like OWL_side1Base, OWL_side2Base?
OWL_mainBases = [missionNamespace getVariable format ["OWL_mainBase_%1", OWL_competingSides # 0], 
				 missionNamespace getVariable format ["OWL_mainBase_%1", OWL_competingSides # 1]];

// Changing mission variables
// Public variables will be sync'd before this is .init'd. The server will init to objNull regardless which means 'vote in progress'
{
	if (missionNamespace getVariable [format ["OWL_currentSector_%1", _x], objNull] == objNull) then {
		missionNamespace setVariable [format ["OWL_currentSector_%1", _x], objNull];
	};
} forEach OWL_competingSides;

