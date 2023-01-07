
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
