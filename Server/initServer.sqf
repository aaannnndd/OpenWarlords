
/******************************************************
***********	 Miscellaneous Housecleaning	***********
******************************************************/

// Remove playable units in SP game
if (!isMultiplayer) then {
	waitUntil { !isNull player };
	{
		if (player != _x) then { deleteVehicle _x; };
	} forEach switchableUnits;
};

// Available from the start
[east, "O_SquadLeader"] call bis_fnc_addRespawnInventory;
[west, "B_SquadLeader"] call bis_fnc_addRespawnInventory;

/******************************************************
***********		Init Serverside Functions	***********
******************************************************/

OWL_fnc_updateSectors = compileFinal preprocessFileLineNumbers "Server\updateSectors.sqf";
OWL_fnc_handleClientRequest = compileFinal preprocessFileLineNumbers "Server\handleClientRequest.sqf";
OWL_fnc_getIncomePayout = compileFinal preprocessFileLineNumbers "Server\getIncomePayout.sqf";
OWL_fnc_updateIncome = compileFinal preprocessFileLineNumbers "Server\updateIncome.sqf";
OWL_fnc_initMapAlterations = compileFinal preprocessFileLineNumbers "Server\initMapAlterations.sqf";
OWL_fnc_updateSpawnPoints = compileFinal preprocessFileLineNumbers "Server\updateSpawnPoints.sqf";

call OWL_fnc_handleClientRequest;

/******************************************************
***********		Init Serverside Globals		***********
******************************************************/

// [ ["_transactionID", "_side", "_amount", "_timestamp"], ... ]
OWL_disconnectedFunds = [];

// [ "UID": [lockedToSide, trasactionID, ...], ... ]
OWL_playerUIDMap = createHashMap;

OWL_allWarlords = [];

OWL_useVanillaIncomeCalculation = (["IncomeCalculation"] call BIS_fnc_getParamValue) == 1;

OWL_maxPlayersForSide = log 0;
{
	if (playableSlotsNumber _x > OWL_maxPlayersForSide) then {
		OWL_maxPlayersForSide = playableSlotsNumber _x;
	};
} forEach OWL_competingSides;


/******************************************************
***********		Init Sectors Serverside		***********
******************************************************/

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
	if (typeOf _x == "Logic" && {count _syncedObjects > 0}) then {	
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
		};
		_x setVariable ["OWL_sectorIncome", _sectorIncome, true];
		_x setVariable ["OWL_sectorFastTravelEnabled", _x getVariable ["OWL_sectorParam_fastTravelEnabled", true], true];
		
		_x setVariable ["OWL_sectorProtected", true];
		
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
			[format ["There are no bases to choose from for %1 side!", OWL_competingSides # _i]] call OWL_fnc_log;
			//(_possibleBases # _i) pushBack (OWL_allSectors # _i);
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
			};
		};
	} forEach OWL_allSectors;
	
	{
		if (isNull _x) then {
			[format ["No base found for %1 side!", OWL_competingSides # _forEachIndex]] call OWL_fnc_log;
			throw "[OWL] Bases init error";
		};
	} forEach OWL_mainBases;
};

publicVariable "OWL_allSectors";
publicVariable "OWL_mainBases";

call OWL_fnc_updateSpawnPoints;

/******************************************************
***********			Main Game Loop 			***********
******************************************************/

OWL_functionUpdateQueue = [
//  ["OWL_fnc_functionToCall",	interval]
	["OWL_fnc_updateSectors",		1	],
	["OWL_fnc_updateIncome", 		60	]
];

[] spawn {

	// is this a good idea?
	
	// idk -_-
	// i improved it a bit
	
	
	{
		_x pushBack time;	// or you can set it to time + interval (_x#1) in case you don't want it to get executed right away
	} forEach OWL_functionUpdateQueue;
	
	while {true} do {
		{
			_x params ["_fncName", "_interval", "_nextTime"];
			if (_nextTime <= time) then {
				call (missionNamespace getVariable [_fncName, {}]);
				_x set [2, time + _interval];
			};
		} forEach OWL_functionUpdateQueue;
		sleep 1;
	};

};

missionNamespace setVariable ["OWL_ServerInitialized", true, true];
