
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
	
	private _player = _clientUserInfo # 10;
	if (isNull _player) exitWith {
		[format ["Player entity of client is null. UserInfo: %1", _clientUserInfo]] call OWL_fnc_log;
		[format ["Kicking out %1 (Failed handshake)", _clientUserInfo # 3]] call OWL_fnc_log;
		if (isMultiplayer && {_owner >= 3}) then {
			serverCommand format ["#kick ""%1""", _clientUserInfo#1];
		}
		else {
			false remoteExec ["OWL_fnc_warlordInitCallback", _owner];
		};
	};
	
	if (isNull group _player || {side group _player == sideUnknown}) exitWith {
		[format ["Could not determine side of the player. UserInfo: %1", _clientUserInfo]] call OWL_fnc_log;
		[format ["Kicking out %1 (Failed handshake)", _clientUserInfo # 3]] call OWL_fnc_log;
		if (isMultiplayer && {_owner >= 3}) then {
			serverCommand format ["#kick ""%1""", _clientUserInfo#1];
		}
		else {
			false remoteExec ["OWL_fnc_warlordInitCallback", _owner];
		};
	};
	
	if ( !((_clientUserInfo#2) call OWL_fnc_tryRemoveFromNonHandshakedClients) ) exitWith {
		[format ["Could not find client in OWL_nonHandshakedClients array. UserInfo: %1", _clientUserInfo]] call OWL_fnc_log;
		[format ["Kicking out %1 (Failed handshake)", _clientUserInfo # 3]] call OWL_fnc_log;
		if (isMultiplayer && {_owner >= 3}) then {
			serverCommand format ["#kick ""%1""", _clientUserInfo#1];
		}
		else {
			false remoteExec ["OWL_fnc_warlordInitCallback", _owner];
		};
	};
	// At this point handshake request should be considered valid
	
	private _success = [_owner, _player] call OWL_fnc_tryInitNewWarlord;
	if (_success || {!((side group _player) in OWL_playableSides)}) then {
		true remoteExec ["OWL_fnc_warlordInitCallback", _owner];
	}
	else {
		false remoteExec ["OWL_fnc_warlordInitCallback", _owner];
	};
};

if (!isMultiplayer) then {
	OWL_fnc_initClientServer = {
		[0, player] call OWL_fnc_tryInitNewWarlord;
		true remoteExec ["OWL_fnc_warlordInitCallback", 0];
	};
};
