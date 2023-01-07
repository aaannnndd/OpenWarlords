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

	// Update UI for team as new votes for each sector come in.
	// This isn't needed client side if we don't want to displayAddEventHandler
	// Which sectors recieve which votes / how many.
};

"OWL_sectorVoteStartTime" addPublicVariableEventHandler {
	// Initialize the UI/Voting bar progress.
	params ["_varName", "_newValue"];
	_votingEnds = _newValue # (OWL_competingSides find (side player));
	_currentSector = missionNamespace getVariable [format ["OWL_currentSector_%1", side player], objNull];

	// Make sure current sector is objNull.
	if (isNull _currentSector) then {
		call OWL_fnc_sectorVoteUIHandle;
	};
};