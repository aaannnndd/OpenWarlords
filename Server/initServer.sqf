
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
OWL_sectorParam_name
OWL_sectorParam_useLocationName
OWL_sectorParam_side
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
publicVariable "OWL_allSectors";

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
