// when a player votes for a sector
OWL_fnc_clientRequestVoteForSector = {
	params ["_sectorId"];
	_clientId = remoteExecutedOwner;
	_player = objectFromNetId _clientId;
	_sector = objectFromNetId _sectorId;
	
	// check if both exist
	// get vote tables for current thing
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