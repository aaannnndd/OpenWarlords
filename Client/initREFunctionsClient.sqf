
OWL_fnc_warlordInitCallback = {
	if (isMultiplayer && {remoteExecutedOwner != 2}) exitWith {};
	if (OWL_serverInitializedMe) exitWith { ["OWL_fnc_warlordInitCallback got called twice?"] call OWL_fnc_log; };
	
	if (_this) then {
		OWL_serverInitializedMe = true;
	}
	else {
		["Client initialization serverside failed. Quitting..."] call OWL_fnc_log;
		endMission "[OWL] Client initialization failed";
		forceEnd;
	};
};

OWL_fnc_sectorVoteTableUpdate = {
	_voteTable = missionNamespace getVariable ["OWL_sectorVoteTable", []];
	_voteTable = _voteTable # (OWL_competingSides find (side player));
};

OWL_fnc_sectorVoteBegin = {
	_votingEnds = OWL_sectorVoteStartTime # (OWL_competingSides find (side player));
	_currentSector = missionNamespace getVariable [format ["OWL_currentSector_%1", side player], objNull];
};

OWL_fnc_sectorSelected = {
	params ["_side", "_newSector"];
	[format ["Client Update: New sector chosen for %1: %2", _side, _newSector getVariable "OWL_sectorName"]] call OWL_fnc_log;
	"BIS_WL_Selected_WEST" call OWL_fnc_eventAnnouncer;
	format ["SECTOR SELECTED: %1", toUpper (_newSector getVariable "OWL_sectorName")] spawn BIS_fnc_WLSmoothText;
	{_x setMarkerAlpha 0;} forEach (_newSector getVariable "OWL_sectorBorderMarkers");
};