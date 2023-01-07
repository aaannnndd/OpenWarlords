
["Server initialization started"] call OWL_fnc_log;

// For simulating long server init times
call {
	for "_i" from 1 to 10000 + 3 do {
		for "_i" from 1 to 1000 do {
			
		};
	};
	["Loop done"] call OWL_fnc_log;
};

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

OWL_startingCP = (["StartingCP"] call BIS_fnc_getParamValue);	// Temporary

// [ ["_transactionID", "_side", "_amount", "_timestamp"], ... ]
OWL_disconnectedFunds = [];

// [ "UID": [lockedToSide, trasactionID, ...], ... ]
OWL_playerUIDMap = createHashMap;

OWL_useVanillaIncomeCalculation = (["IncomeCalculation"] call BIS_fnc_getParamValue) == 1;

OWL_maxPlayersForSide = log 0;
{
	if (playableSlotsNumber _x > OWL_maxPlayersForSide) then {
		OWL_maxPlayersForSide = playableSlotsNumber _x;
	};
} forEach OWL_competingSides;

OWL_allWarlordsData = [];
OWL_ownerToDataIndexMap = createHashMap;
OWL_nonitializedPlayersIds = [];


/******************************************************
***********	Init Serverside Event Handlers	***********
******************************************************/

// See https://feedback.bistudio.com/T123355 to know why we using call instead of directly assigning code to event handler

OWL_EH_onPlayerConnected = {
	params ["_dpId", "_uid", "_name", "_jip", "_owner", "_dpIdStr"];
	["PlayerConnected EH: " + str _this] call OWL_fnc_log;
	
	// See https://community.bistudio.com/wiki/Arma_3:_Mission_Event_Handlers#PlayerConnected
	// Without isDedicated check it will also trigger for host in player hosted game
	if (_owner == 2 && {isDedicated}) exitWith {
		["PlayerConnected EH fired against dedicated server, ignoring. Params: " + str _this] call OWL_fnc_log;
	};
	if (getUserInfo _dpIdStr # 7) exitWith {
		["PlayerConnected EH fired against headless client, ignoring. Params: " + str _this] call OWL_fnc_log;
	};
	OWL_nonitializedPlayersIds pushBackUnique _owner;
};

OWL_EH_onPlayerDisconnected = {
	params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];
	["PlayerDisconnected EH: " + str _this] call OWL_fnc_log;
	
	_owner call OWL_fnc_popNonitializedPlayerId;
	_owner call OWL_fnc_tryDeleteWarlordData;
};

OWL_EH_onEntityRespawned = {
	params ["_newEntity", "_oldEntity"];
	["EntityRespawned EH: " + str _this] call OWL_fnc_log;
	
	if (!isPlayer _newEntity) exitWith { ["Respawned entity is not player"] call OWL_fnc_log; };
	
	private _owner = owner _newEntity;
	if (_owner call OWL_fnc_popNonitializedPlayerId) then {
		[_owner, _newEntity] call OWL_fnc_tryInitNewWarlord;
	};
};

addMissionEventHandler ["EntityRespawned", { _this call OWL_EH_onEntityRespawned; }];
addMissionEventHandler ["PlayerDisconnected", { _this call OWL_EH_onPlayerDisconnected; }];
addMissionEventHandler ["PlayerConnected", { _this call OWL_EH_onPlayerConnected; }];


/******************************************************
***********			Finishing up 			***********
******************************************************/

// In case there are players that joined before event handlers were added
{
	private _userInfo = getUserInfo _x;
	_userInfo params ["_playerID", "_ownerId", "_playerUID", "_profileName", "_displayName", "_steamName", "_clientState", "_isHC", "_adminState", "_networkInfo", "_unit"];
	
	if (_ownerId == 2 && {isDedicated}) then { continue; };
	if (_ownerId < 2) then { continue; };
	
	_ownerId call OWL_fnc_popNonitializedPlayerId;
	[_ownerId, _unit] call OWL_fnc_tryInitNewWarlord;
} forEach (allUsers);

[] spawn compileFinal preprocessFileLineNumbers "Server\playersProcessingLoop.sqf";

missionNamespace setVariable ["OWL_ServerInitialized", true, true];
["Server initialization finished"] call OWL_fnc_log;

/******************************************************
***********			Begin the game 			***********
******************************************************/

// OTE: Sector voting is triggered by the first 'sector vote' request given that the current sector is objNull.
// This will set in motion the actual 'game loop'.