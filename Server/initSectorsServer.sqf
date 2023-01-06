
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

OWL_sectorParam_income:
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
		_x setVariable ["OWL_sectorSide",
			[sideEmpty, OWL_competingSides#0, OWL_competingSides#1, OWL_defendingSide] # (_x getVariable ["OWL_sectorParam_side", 0]),
		true];
		
		private _sectorIncome = _x getVariable "OWL_sectorParam_income";
		if (isNil "_sectorIncome") then {
			// If income parameter is undefined use weird formula to calculate sector income based on its size
			_sectorIncome = (round ((_triggerArea#0 + _triggerArea#1) / 100)) * 5;
			if (_sectorIncome < 5) then { _sectorIncome = 5; };
		};
		_x setVariable ["OWL_sectorIncome", _sectorIncome, true];
		_x setVariable ["OWL_sectorFastTravelEnabled", _x getVariable ["OWL_sectorParam_fastTravelEnabled", true], true];
		
		_x setVariable ["OWL_sectorProtected", true];
		
		_x enableSimulationGlobal false;
		
		OWL_allSectors pushBack _x;
	};
} forEach (entities "Logic");

if (["BaseLocation"] call BIS_fnc_getParamValue == 1) then {
	// Choose random base location
	
	private _possibleBases = [[],[]];
	
	{
		if (_x getVariable ["OWL_sectorParam_canBeBase", 0] >= 1) then {
			switch (_x getVariable ["OWL_sectorParam_side", 0]) do {
				case 1: { (_possibleBases#0) pushBack _x; };
				case 2: { (_possibleBases#1) pushBack _x; };
				default { ["Bases can only be owned by competing sides!"] call OWL_fnc_log; };
			};
		};
	} forEach OWL_allSectors;
	
	for "_i" from 0 to 1 do {
		if (count (_possibleBases # _i) == 0) then {
			[format ["There are no bases to choose from for side %1!", _i]] call OWL_fnc_log;
			throw "[OWL] Bases init error";
		};
	};
	
	OWL_mainBases = [ selectRandom (_possibleBases#0), selectRandom (_possibleBases#1) ];
}
else {
	// Find default bases
	
	OWL_mainBases = [objNull, objNull];
	
	{
		if (_x getVariable ["OWL_sectorParam_canBeBase", 0] == 2) then {
			private _side = _x getVariable ["OWL_sectorParam_side", 0];
			if (_side != 1 && {_side != 2}) then {
				["Bases can only be owned by competing sides!"] call OWL_fnc_log;
				continue;
			};
			_side = _side - 1;
			if (isNull (OWL_mainBases # _side)) then {
				OWL_mainBases set [_side, _x];
			}
			else {
				[format ["There are more than one default base for side %1!", _side]] call OWL_fnc_log;
			};
		};
	} forEach OWL_allSectors;
	
	{
		if (isNull _x) then {
			[format ["No base found for side %1!", _forEachIndex]] call OWL_fnc_log;
			throw "[OWL] Bases init error";
		};
	} forEach OWL_mainBases;
};

publicVariable "OWL_allSectors";
publicVariable "OWL_mainBases";

call OWL_fnc_updateSpawnPoints;
