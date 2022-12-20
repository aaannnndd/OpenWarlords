// Helper function
OWL_fnc_getPlayerFromNetId = {
	params ["_netId"];

	_player = objNull;
	{
		if (owner _x == _netId) then {
			_player = _x;
		};
	} for allPlayers;

	_player;
};

// when a player votes for a sector
OWL_sectorVoteTable = [createHashMap,createHashMap];
OWL_sectorVoteStartTime = [-1,-1];
OWL_sectorVoteTimer = 30;
OWL_fnc_clientRequestVoteForSector = {
	params ["_sectorId"];
	_clientId = remoteExecutedOwner;
	systemChat format ["%1, %2, %3", _clientId, _sectorId];
	_player = _clientId call OWL_fnc_getPlayerFromNetId;
	_sector = objectFromNetId _sectorId;
	
	_sideIdx = OWL_competingSides find (side _player);
	_voteTable = OWL_sectorVoteTable # _sideIdx;

	// If this is the first vote - begin the countdown timer.
	if (count _voteTable == 0) then {
		OWL_sectorVoteStartTime set [_sideIdx, serverTime + OWL_sectorVoteTimer];
		publicVariable "OWL_sectorVoteStartTime";

		_sideIdx spawn {
			while {(OWL_sectorVoteStartTime # _this) >= serverTime} do {sleep 1;};

			_mostVoted = -1;
			_voteCount = 0;
			{
				if (_y > _voteCount) then {
					_voteCount = _y;
					_mostVoted = _x;
				};
			} forEach (OWL_sectorVoteTable # _this);

			OWL_sectorVoteTable set [_this, createHashMap];
			OWL_sectorVoteStartTime set [_this, -1];

			_nextSector = objectFromNetId _mostVoted;
			[_sideIdx, _nextSector] call OWL_fnc_handleSectorSelected;
		};
	};

	_votes = _voteTable getOrDefault [_sectorId, 0];
	_votes = _votes + 1;
	_voteTable set [_sectorId, _votes];
	publicVariable "OWL_sectorVoteTable";
};

// Decide if player should be punished for a teamkill.
OWL_fnc_clientRequestVotePunish = {
	params ["_verdict", "_defendantId"];
	_clientId = remoteExecutedOwner;
	_defendant = objectFromNetId _defendantId;
	_victim = objectFromNetId _clientId;

	switch {_verdict} do {
		case "punish":
		{

		};
		case "forgive":
		{

		};
	};
};

// Request sector reset, maybe vote on it.
OWL_fnc_clientRequestSectorReset = {

};