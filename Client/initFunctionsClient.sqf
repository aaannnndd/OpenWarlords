
OWL_fnc_handleServerUpdate = compileFinal preprocessFileLineNumbers "Client\handleServerUpdate.sqf";
OWL_fnc_sectorLocationName = compileFinal preprocessFileLineNumbers "Client\sectorLocationName.sqf";
OWL_fnc_voteNewSectorPrompt = compileFinal preprocessFileLineNumbers "Client\voteNewSectorPrompt.sqf";
OWL_fnc_eventAnnouncer = compileFinal preprocessFileLineNumbers "Client\eventAnnouncer.sqf";
OWL_fnc_sectorVoteUIHandle = compileFinal preprocessFileLineNumbers "Client\sectorVoteUIHandle.sqf";

OWL_fnc_sideToMarkerColor = {
	switch (_this) do {
		case WEST:			{ "ColorWEST" };
		case EAST:			{ "ColorEAST" };
		case RESISTANCE:	{ "ColorGUER" };
		case CIVILIAN:		{ "ColorCIV" };
		default				{ "ColorBlack" };
	};
};
