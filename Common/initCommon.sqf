#include "..\defines.hpp"

call compileFinal preprocessFileLineNumbers "Common\initFunctions.sqf";
call compileFinal preprocessFileLineNumbers "Common\initVars.sqf";

// Changing mission variables
// Public variables will be sync'd before this is .init'd. The server will init to objNull regardless which means 'vote in progress'
{
	if (missionNamespace getVariable [format ["OWL_currentSector_%1", _x], objNull] == objNull) then {
		missionNamespace setVariable [format ["OWL_currentSector_%1", _x], objNull];
	};
} forEach OWL_competingSides;


