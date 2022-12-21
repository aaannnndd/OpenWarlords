
call compileFinal preprocessFileLineNumbers "Server\initFunctionsServer.sqf";
call compileFinal preprocessFileLineNumbers "Server\initSectorsServer.sqf";


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
