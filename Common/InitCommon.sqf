
// Static Mission Variables
OWL_competingSides = [WEST, EAST];
OWL_defendingSide = [RESISTANCE];
OWL_mainBases = [missionNamespace getVariable format ["OWL_mainBase_%1", OWL_competingSides # 0], 
				 missionNamespace getVariable format ["OWL_mainBase_%1", OWL_competingSides # 1]];
OWL_maxPlayersForSide = 25;

// Changing mission variables
// Public variables will be sync'd before this is .init'd. The server will init to objNull regardless which means 'vote in progress'
{
	if (missionNamespace getVariable [format ["OWL_currentSector_%1", _x], objNull] == objNull) then {
		missionNamespace setVariable [format ["OWL_currentSector_%1", _x], objNull];
	};
} forEach OWL_competingSides;


