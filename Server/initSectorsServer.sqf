
/* Possible sector parameters

OWL_sectorParam_canBeBase
	0 - Can't be base
	1 - Can be base
	2 - Can be base and default base if randomization is disabled
	
OWL_sectorParam_name
	Any string to use as a sector name

OWL_sectorParam_useLocationName
	True - name parameter is ignored and location name is used instead
	False - name parameter is ignored only if it is empty string or undefined

OWL_sectorParam_side
	Indicates who owns the sector at the start of the game
	0 - Unclaimed
	1 - Competing side 1
	2 - Competing side 2
	3 - Defending side

OWL_sectorParam_income
OWL_sectorParam_hasHarbour
OWL_sectorParam_hasHelipad
OWL_sectorParam_hasRunway
OWL_sectorParam_fastTravelEnabled
OWL_sectorParam_borderSize
*/

OWL_allSectors = [];

{
	private _syncedObjects = synchronizedObjects _x;
	// We do typeOf check because entities command also returns entities deriving from the given type
	if (typeOf _x == "Logic" && {count _syncedObjects > 0} && {!(_x getVariable ["OWL_isNotSector", false])}) then {	
		private _trigger = _syncedObjects findIf { typeOf _x == "EmptyDetector" };
		if (_trigger == -1) then { continue };
		_trigger = _syncedObjects # _trigger;
		private _triggerPos = getPosASL _trigger;
		private _triggerArea = triggerArea _trigger;
		deleteVehicle _trigger;
		
		_triggerPos deleteAt 2;
		_triggerArea deleteAt 4;
		_x setPosATL [_triggerPos#0, _triggerPos#1, 0];
		_x setVariable ["OWL_sectorArea", [_triggerPos] + _triggerArea, true];
		private _sectorSide = [sideEmpty, OWL_competingSides#0, OWL_competingSides#1, OWL_defendingSide] # (_x getVariable ["OWL_sectorParam_side", 0]);
		_x setVariable ["OWL_sectorSide", _sectorSide, false];
		
		//_x setVariable ["OWL_previousOwners", [_sectorSide], true];
		
		private _sectorIncome = _x getVariable "OWL_sectorParam_income";
		if (isNil "_sectorIncome") then {
			// If income parameter is undefined use weird formula to calculate sector income based on its size
			_sectorIncome = (round ((_triggerArea#0 + _triggerArea#1) / 100)) * 5;
			if (_sectorIncome < 5) then { _sectorIncome = 5; };
		};
		_x setVariable ["OWL_sectorIncome", _sectorIncome, true];
		_x setVariable ["OWL_sectorFastTravelEnabled", _x getVariable ["OWL_sectorParam_fastTravelEnabled", true], true];
		
		_x setVariable ["OWL_sectorProtected", true, true];
		
		_x enableSimulationGlobal false;
		
		private _sectorID = OWL_allSectors pushBack _x;
		_x setVariable ["OWL_sectorID", _sectorID, false];
	};
} forEach (entities "Logic");

OWL_mainBases = [];

if (["BaseLocation"] call BIS_fnc_getParamValue == 1) then {
	// Choose random base location
	
	private _possibleBases = [];
	{ _possibleBases pushBack []; } forEach OWL_competingSides;
	
	{
		if (_x getVariable ["OWL_sectorParam_canBeBase", 0] >= 1) then {
			private _index = OWL_competingSides find (_x getVariable ["OWL_sectorSide", 0]);
			if (_index != -1) then {
				(_possibleBases # _index) pushBack _x;
			}
			else {
				["Bases can only be owned by competing sides!"] call OWL_fnc_log;
			}
		};
	} forEach OWL_allSectors;
	
	{
		if (count _x == 0) then {
			[format ["There are no bases to choose from for side %1!", OWL_competingSides # _forEachIndex]] call OWL_fnc_log;
			endMission "[OWL] Initialization error";
		};
		OWL_mainBases pushBack selectRandom _x;
	} forEach _possibleBases;
}
else {
	// Find default bases
	
	{ OWL_mainBases pushBack objNull; } forEach OWL_competingSides;
	
	{
		if (_x getVariable ["OWL_sectorParam_canBeBase", 0] == 2) then {
			private _index = OWL_competingSides find (_x getVariable ["OWL_sectorSide", 0]);
			if (_index != -1) then {
				if (isNull (OWL_mainBases # _index)) then {
					OWL_mainBases set [_index, _x];
				}
				else {
					[format ["There are more than one default base for side %1!", OWL_competingSides # _index]] call OWL_fnc_log;
				};
			}
			else {
				["Bases can only be owned by competing sides!"] call OWL_fnc_log;
			};
		};
	} forEach OWL_allSectors;
	
	{
		if (isNull _x) then {
			[format ["No base found for side %1!", OWL_competingSides # _forEachIndex]] call OWL_fnc_log;
			endMission "[OWL] Initialization error";
		};
	} forEach OWL_mainBases;
};

publicVariable "OWL_allSectors";
publicVariable "OWL_mainBases";

call OWL_fnc_updateSpawnPoints;
