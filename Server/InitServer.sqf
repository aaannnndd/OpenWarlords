#include "..\defines.hpp"

/******************************************************
***********	 Miscellaneous Housecleaning	***********  
******************************************************/

// Remove playable units in SP game
if (not isMultiplayer) then {
	waitUntil { not isNull player };
	{
		if (player != _x) then { deleteVehicle _x; };
	} forEach switchableUnits;
};

/******************************************************
***********		 Init Sector Variables		***********  
******************************************************/
{
	_x setVariable ["OWL_sectorProtected", true];
} forEach OWL_allSectors;

/******************************************************
***********		Init Serverside Globals		***********  
******************************************************/

// [ ["_transactionID", "_side", "_amount", "_timestamp"], ... ]
OWL_disconnectedFunds = [];

// [ "UID": [lockedToSide, trasactionID, ...], ... ]
OWL_playerUIDMap = createHashMap;

OWL_allWarlords = [];


/******************************************************
***********			Main Game Loop 			***********  
******************************************************/

OWL_functionUpdateQueue = [
//  [OWL_fnc_functionToCall, timer, timerResetValue]
	[OWL_fnc_updateSectors,	1, 		1],
	[OWL_fnc_updateIncome, 	60, 	60]
];

OWL_mainGameLoopHandle = [] spawn {

	// is this a good idea?
	_lastTime = serverTime;
	while {TRUE} do {
		_diff = serverTime - _lastTime;
		_lastTime = serverTime;

		{
			_x params ["_fnc", "_timer"];
			_timer = _timer - _diff;
			if (_diff <= 0) then {
				call _fnc;
				_x set [1, _x select 2];
			};
		} forEach OWL_functionUpdateQueue;
		sleep 1;
	};

};