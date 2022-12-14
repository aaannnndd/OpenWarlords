#include "..\defines.hpp"

OWL_fnc_initClientServer = {
	private _owner = remoteExecutedOwner;
	if (!isRemoteExecuted || {_owner < 2}) exitWith {
		[format ["Handshake sanity check failed [isRemoteExecuted: %1, Owner ID: %2]", isRemoteExecuted, _owner]] call OWL_fnc_log;
	};
	
	private _clientUserInfo = [];
	{
		private _userInfo = getUserInfo _x;
		if (_userInfo#1 == _owner) then {
			_clientUserInfo = _userInfo;
			break;
		};
	} forEach allUsers;
	
	if (count _clientUserInfo == 0) exitWith {
		[format ["Failed to retrieve client's info [Owner ID: %1]", _owner]] call OWL_fnc_log;
		false remoteExec ["OWL_fnc_warlordInitCallback", _owner];
	};
	
	private _uid = _clientUserInfo # 2;
	private _name = _clientUserInfo # 3;
	private _player = _clientUserInfo # 10;
	
	if (isNull _player) exitWith {
		[format ["Player entity of client is null. UserInfo: %1", _clientUserInfo]] call OWL_fnc_log;
		false remoteExec ["OWL_fnc_warlordInitCallback", _owner];
		if (_owner >= 3) then {
			[_uid, _name, "Failed handshake"] call OWL_fnc_kickPlayer;
		};
	};
	
	if (isNull group _player || {side group _player == sideUnknown}) exitWith {
		[format ["Could not determine side of the player. UserInfo: %1", _clientUserInfo]] call OWL_fnc_log;
		false remoteExec ["OWL_fnc_warlordInitCallback", _owner];
		if (_owner >= 3) then {
			[_uid, _name, "Failed handshake"] call OWL_fnc_kickPlayer;
		};
	};
	
	if ( !(_uid call OWL_fnc_tryRemoveFromNonHandshakedClients) ) exitWith {
		[format ["Could not find client in OWL_nonHandshakedClients array. UserInfo: %1", _clientUserInfo]] call OWL_fnc_log;
		false remoteExec ["OWL_fnc_warlordInitCallback", _owner];
		if (_owner >= 3) then {
			[_uid, _name, "Failed handshake"] call OWL_fnc_kickPlayer;
		};
	};
	// At this point handshake request should be considered valid
	
	private _success = [_owner, _uid, _player] call OWL_fnc_tryInitNewWarlord;
	if (_success || {!((side group _player) in OWL_playableSides)}) then {
		true remoteExec ["OWL_fnc_warlordInitCallback", _owner];
	}
	else {
		false remoteExec ["OWL_fnc_warlordInitCallback", _owner];
	};
};

if (!isMultiplayer) then {
	OWL_fnc_initClientServer = {
		[0, getPlayerUID player, player] call OWL_fnc_tryInitNewWarlord;
		true remoteExec ["OWL_fnc_warlordInitCallback", 0];
	};
};


// when a player votes for a sector
OWL_sectorVoteTable = [createHashMap,createHashMap];
OWL_sectorVoteStartTime = [-1,-1];
OWL_sectorVoteTimer = 30;

OWL_fnc_clientRequestVoteForSector = {
	params ["_sectorId"];
	_clientId = remoteExecutedOwner;
	_sideIdx = OWL_competingSides find (GET_WARLORD_SIDE((_clientId call OWL_fnc_getWarlordDataByOwnerId)));
	_voteTable = OWL_sectorVoteTable # _sideIdx;

	// If this is the first vote - begin the countdown timer.
	if (count _voteTable == 0) then {
		OWL_sectorVoteStartTime set [_sideIdx, (call OWL_fnc_syncedTime) + OWL_sectorVoteTimer];
		publicVariable "OWL_sectorVoteStartTime";
		remoteExec ["OWL_fnc_sectorVoteBegin", OWL_competingSides # _sideIdx];

		_sideIdx spawn {
			while {(OWL_sectorVoteStartTime # _this) >= (call OWL_fnc_syncedTime)} do {sleep 1;};

			_mostVoted = -1;
			_voteCount = 0;
			{
				if (count _y > _voteCount) then {
					_voteCount = count _y;
					_mostVoted = _x;
				};
			} forEach (OWL_sectorVoteTable # _this);

			OWL_sectorVoteTable set [_this, createHashMap];
			OWL_sectorVoteStartTime set [_this, -1];

			_nextSector = objectFromNetId _mostVoted;
			[_this, _nextSector] call OWL_fnc_handleSectorSelected;
		};
	};

	// If they already voted for something, delete old vote before adding new one.
	{
		if (_clientId in _y) then {
			if (count _y == 1) then {
				_voteTable deleteAt _x;
			} else {
				_voteTable set [_x,_y - [_clientId]];
			};
		};
	} forEach _voteTable;

	_voteList = _voteTable getOrDefault [_sectorId, []];
	_voteList pushBackUnique _clientId;
	_voteTable set [_sectorId, _voteList];
	publicVariable "OWL_sectorVoteTable";
	remoteExec ["OWL_fnc_sectorVoteTableUpdate", OWL_competingSides # _sideIdx];
};