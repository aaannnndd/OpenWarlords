#include "..\defines.hpp"

// initClientServer
OWL_fnc_ICS = {
	if (!isMultiplayer) exitWith {
		//[0, getPlayerUID player, player] call OWL_fnc_tryInitNewWarlord;
		//[true] remoteExecCall ["OWL_fnc_WIC", 0];
		
		["DON'T RUN THIS SCENARIO IN SP IT WON'T WORK!"] call OWL_fnc_log;
		[false] remoteExecCall ["OWL_fnc_WIC", 0];
	};
	
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
		[false] remoteExecCall ["OWL_fnc_WIC", _owner];
	};
	
	private _uid = _clientUserInfo # 2;
	private _player = _clientUserInfo # 10;
	
	if (isNull _player) exitWith {
		[format ["Player entity of client is null. UserInfo: %1", _clientUserInfo]] call OWL_fnc_log;
		[false] remoteExecCall ["OWL_fnc_WIC", _owner];
		if (_owner >= 3) then { [_uid, "Failed handshake"] call OWL_fnc_kickPlayer; };
	};
	
	private _side = side group _player;
	
	if (isNull group _player || {_side == sideUnknown}) exitWith {
		[format ["Could not determine side of the player. UserInfo: %1", _clientUserInfo]] call OWL_fnc_log;
		[false] remoteExecCall ["OWL_fnc_WIC", _owner];
		if (_owner >= 3) then { [_uid, "Failed handshake"] call OWL_fnc_kickPlayer; };
	};
	
	if ( !(_uid call OWL_fnc_tryRemoveFromNonHandshakedClients) ) exitWith {
		[format ["Could not find client in OWL_nonHandshakedClients array. UserInfo: %1", _clientUserInfo]] call OWL_fnc_log;
		[false] remoteExecCall ["OWL_fnc_WIC", _owner];
		if (_owner >= 3) then { [_uid, "Failed handshake"] call OWL_fnc_kickPlayer; };
	};
	
	private _handshakeIsValid = false;
	private _initializedAsWarlord = false;
	
	if (_side in OWL_playableSides) then {
		_initializedAsWarlord = [_owner, _uid, _player] call OWL_fnc_tryInitNewWarlord;
		_handshakeIsValid = _initializedAsWarlord;
		if (!_initializedAsWarlord) then {
			[format ["Could not initialize new warlord. UserInfo: %1", _clientUserInfo]] call OWL_fnc_log;
			if (_owner >= 3) then { [_uid, "Failed handshake"] call OWL_fnc_kickPlayer; };
		};
	}
	else {
		_handshakeIsValid = true;
	};
	
	if (!_handshakeIsValid) exitWith { [false] remoteExecCall ["OWL_fnc_WIC", _owner]; };
	
	
	// HERE WE ARE BUILDING THE DATA ARRAY WHICH WE SEND TO THE NEW CLIENT
	//  ||
	//  ||
	//  \/
	
	isNil {
		private _jipData = [];
		
		// Gathering public data about sectors
		private _sectorsData = [];
		{
			_sectorsData pushBack [
				_x getVariable "OWL_sectorSide"
			];
		} forEach OWL_allSectors;
		_jipData pushBack _sectorsData;
		
		// Gathering public data about sides (targeted sector)
		private _publicSidesData = [];
		{
			private _sideInfo = OWL_competingSidesInfo get _side;
			_publicSidesData pushBack [
				_sideInfo get "OWL_targetedSector"
			];
		} forEach OWL_competingSides;
		_jipData pushBack _publicSidesData;
		
		if (_initializedAsWarlord) then {
			// Gathering side specific private data
			private _sideSpecificData = [];
			
			private _sideInfo = OWL_competingSidesInfo get _side;
			
			private _scanStartTime = _sideInfo get "OWL_scanStartTime";
			if (_scanStartTime != -1) then {
				_sideSpecificData pushBack [_scanStartTime, _sideInfo get "OWL_scanDuration"];
			}
			else {
				_sideSpecificData pushBack [_scanStartTime];
			};
			
			private _votingStartTime = _sideInfo get "OWL_votingStartTime";
			if (_votingStartTime != -1) then {
				_sideSpecificData pushBack [_votingStartTime, _sideInfo get "OWL_sectorVotes"];
			}
			else {
				_sideSpecificData pushBack [_votingStartTime];
			};
			
			_jipData pushBack _sideSpecificData;
			
			// Gathering player specific data
			private _warlordInfo = _owner call OWL_fnc_getWarlordDataByOwnerId;
			_jipData pushBack [GET_WARLORD_FUNDS(_warlordInfo)];
		};
		
		// We ended up with
		// _jipData = [ [sectors data], [public data about each side], [side specific data: [scan start, scan duration], [voting start, [votes for each sector]]], [player specific data] ]
		[_handshakeIsValid, _jipData] remoteExecCall ["OWL_fnc_WIC", _owner];
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
	remoteExecCall ["OWL_fnc_sectorVoteTableUpdate", OWL_competingSides # _sideIdx];
};