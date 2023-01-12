#include "..\owl_constants.hpp"
#include "..\defines.hpp"

["Server initialization started"] call OWL_fnc_log;

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

OWL_startingFunds = (["StartingFunds"] call BIS_fnc_getParamValue);
OWL_useVanillaIncomeCalculation = (["IncomeCalculation"] call BIS_fnc_getParamValue) == 1;
OWL_saveWarlordFunds = (["SaveFunds"] call BIS_fnc_getParamValue) == 1;

OWL_maxPlayersForSide = log 0;
{
	if (playableSlotsNumber _x > OWL_maxPlayersForSide) then {
		OWL_maxPlayersForSide = playableSlotsNumber _x;
	};
} forEach OWL_playableSides;

// [ [owner ID, player entity, side, funds], ... ]
OWL_allWarlordsData = [];
OWL_ownerToDataIndexMap = createHashMap;
OWL_nonHandshakedClients = [];
// [ UID: [disconnectionTime, side, funds], ... ]
OWL_persistentWarlordsData = createHashMap;

/******************************************************
***********	Init Serverside Event Handlers	***********
******************************************************/

// See https://feedback.bistudio.com/T123355 to understand why we use call instead of directly assigning code to the event handlers

OWL_EH_onPlayerConnected = {
	params ["_dpId", "_uid", "_name", "_jip", "_owner", "_dpIdStr"];
	["PlayerConnected EH: " + str _this] call OWL_fnc_log;
	
	// See https://community.bistudio.com/wiki/Arma_3:_Mission_Event_Handlers#PlayerConnected
	// Without isDedicated check it will also trigger for host in player hosted game
	if (_owner == 2 && {isDedicated}) exitWith {
		["PlayerConnected EH fired against dedicated server, ignoring. Params: " + str _this] call OWL_fnc_log;
	};
	
	_uid call OWL_fnc_tryRemoveFromNonHandshakedClients;
	OWL_nonHandshakedClients pushBack [_uid, time + HANDSHAKE_TIMEOUT, _owner, _name];
};

OWL_EH_onPlayerDisconnected = {
	params ["_dpId", "_uid", "_name", "_jip", "_owner", "_dpIdStr"];
	["PlayerDisconnected EH: " + str _this] call OWL_fnc_log;
	
	_uid call OWL_fnc_tryRemoveFromNonHandshakedClients;
	[_owner, _uid] call OWL_fnc_tryDeinitWarlord;
};

OWL_EH_onEntityRespawned = {
	params ["_newEntity", "_oldEntity"];
	["EntityRespawned EH: " + str _this] call OWL_fnc_log;
	
	if (!isPlayer _newEntity) exitWith { ["Respawned entity is not a player"] call OWL_fnc_log; };
	
	private _owner = owner _newEntity;
	private _warlordInfo = _owner call OWL_fnc_getWarlordDataByOwnerId;
	if (!WARLORD_DATA_IS_NULL(_warlordInfo)) then {
		SET_WARLORD_PLAYER(_warlordInfo, _newEntity);
	};
};

addMissionEventHandler ["EntityRespawned", { _this call OWL_EH_onEntityRespawned; }];
if (isMultiplayer) then {
	addMissionEventHandler ["PlayerDisconnected", { _this call OWL_EH_onPlayerDisconnected; }];
	addMissionEventHandler ["PlayerConnected", { _this call OWL_EH_onPlayerConnected; }];
};


/******************************************************
***********			Finishing up 			***********
******************************************************/

OWL_competingSidesInfo = createHashMap;
{
	private _sideInfo = createHashMap;
	_sideInfo set ["OWL_targetedSector", -1];
	_sideInfo set ["OWL_scanStartTime", -1];
	_sideInfo set ["OWL_scanDuration", -1];
	//_sideInfo set ["OWL_votingIsActive", false];
	_sideInfo set ["OWL_votingStartTime", -1];
	//_sideInfo set ["OWL_votingDuration", -1];
	_sideInfo set ["OWL_sectorVotes", []];
	
	OWL_competingSidesInfo set [_x, _sideInfo];
} forEach OWL_competingSides;

// In case there are players that joined before event handlers were added
{
	(getUserInfo _x) params ["_playerID", "_ownerId", "_playerUID", "_profileName", "_displayName", "_steamName", "_clientState", "_isHC", "_adminState", "_networkInfo", "_unit"];
	
	_playerUID call OWL_fnc_tryRemoveFromNonHandshakedClients;
	OWL_nonHandshakedClients pushBack [_playerUID, time + HANDSHAKE_TIMEOUT, _ownerId, _profileName];
} forEach allUsers;


if (HANDSHAKE_TIMEOUT > 0 && {isMultiplayer}) then {
	// Kick clients that don't send handshake loop
	[] spawn { while {true} do {
		{
			_x params ["_uid", "_kickTime", "_owner", "_name"];
			
			if (time > _kickTime) then {
				[format ["Handshake timed out for %1", _name]] call OWL_fnc_log;
				if (_owner >= 3) then {
					[_uid, "Handshake timed out"] call OWL_fnc_kickPlayer;
				};
				_uid call OWL_fnc_tryRemoveFromNonHandshakedClients;
			};
		} forEach OWL_nonHandshakedClients;
		sleep 1;
	};};
};

[] spawn compileFinal preprocessFileLineNumbers "Server\playerProcessingLoop.sqf";
call compileFinal preprocessFileLineNumbers "Server\initREFunctionsServer.sqf";

missionNamespace setVariable ["OWL_serverInitialized", true, true];
["Server initialization finished"] call OWL_fnc_log;


/******************************************************
***********			Begin the game 			***********
******************************************************/

// OTE: Sector voting is triggered by the first 'sector vote' request given that the current sector is objNull.
// This will set in motion the actual 'game loop'.