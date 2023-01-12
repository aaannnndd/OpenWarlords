
/******************************************************
***********		Init Common Functions		***********
******************************************************/

OWL_fnc_calculateAttackableSectors = compileFinal preprocessFileLineNumbers "Common\calculateAttackableSectors.sqf";
OWL_fnc_calculateProtectableSectors = compileFinal preprocessFileLineNumbers "Common\calculateProtectableSectors.sqf";
OWL_fnc_calculateSectorRelationships = compileFinal preprocessFileLineNumbers "Common\calculateSectorRelationships.sqf";
OWL_fnc_calculateLinkedSectors = compileFinal preprocessFileLineNumbers "Common\calculateLinkedSectors.sqf";

OWL_fnc_log = {
	private _msg = "[OWL] " + _this#0;
	if (OWL_devMode && hasInterface) then {
		systemChat _msg;
	};
	diag_log _msg;
};

if (isMultiplayer) then {
  OWL_fnc_syncedTime = { serverTime };
}
else {
  OWL_fnc_syncedTime = { time };
};


/******************************************************
***********		Init Common Globals			***********
******************************************************/

OWL_competingSides = [[WEST, EAST], [WEST, RESISTANCE], [EAST, RESISTANCE]] # (["Combatants"] call BIS_fnc_getParamValue);
OWL_defendingSide = [RESISTANCE, EAST, WEST, RESISTANCE] # (["Combatants"] call BIS_fnc_getParamValue);
OWL_defendersPlayable = (["DefendersPlayable"] call BIS_fnc_getParamValue) == 1;
DefendersCanAttack = OWL_defendersPlayable && {(["DefendersCanAttack"] call BIS_fnc_getParamValue) == 1};

OWL_playableSides = +OWL_competingSides;
if (OWL_defendersPlayable) then { OWL_playableSides pushBack OWL_defendingSide; };
if (DefendersCanAttack) then { OWL_competingSides pushBack OWL_defendingSide; };
