// Sector Changed
OWL_fnc_sectorChanged = {
	// Sector changed for side 1 (or sector captured)
	_variableName = _this # 0;
	_newContested = _this # 1;

	if (!isNull _newContested) then {
		if ( (str (side player)) in _variableName ) then {
			// Sector Selected
		} else {
			// Enemy Advancing
		};
	};
	// UI updates
};

(format ["OWL_currentSector_%1", OWL_competingSides # 0]) addPublicVariableEventHandler OWL_fnc_sectorChanged;
(format ["OWL_currentSector_%1", OWL_competingSides # 1]) addPublicVariableEventHandler OWL_fnc_sectorChanged;

"OWL_sectorVoteTable" addPublicVariableEventHandler {
	// Update the UI/Voting bar progress
	params ["_varName", "_newValue"];
	_side = side player;

	// If vote is't in progress or no votes exist, ignore.
	if ( count (_newValue # _side) > 0 && (OWL_sectorVoteStartTime # _side) > serverTime ) then {

	};
};

"OWL_sectorVoteStartTime" addPublicVariableEventHandler {
	// Initialize the UI/Voting bar progress.
	params ["_varName", "_newValue"];
	_votingEnds = _newValue # (side player);

	// Make sure it's our sides fucking vote.
	if (_votingEnds > 0 && _votingEnds > serverTime ) then {

	};
};