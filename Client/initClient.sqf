
/******************************************************
***********		Init Clientside Functions	***********
******************************************************/

OWL_fnc_handleServerUpdate = compileFinal preprocessFileLineNumbers "Client\handleServerUpdate.sqf";
OWL_fnc_sectorLocationName = compileFinal preprocessFileLineNumbers "Client\sectorLocationName.sqf";


waitUntil { !isNull player };
waitUntil { missionNamespace getVariable ["OWL_ServerInitialized", false] };


/******************************************************
***********		Init Sectors Clientside		***********
******************************************************/

{
	private _sectorName = _x getVariable ["OWL_sectorParam_name", ""];
	if ( _sectorName == "" || { _x getVariable ["OWL_sectorParam_useLocationName", false] } ) then {
		if (_x in OWL_mainBases) then {
			switch (_x getVariable "OWL_sectorSide") do {
				case WEST: { _sectorName = localize "STR_A3_WL_default_base_blufor"; };
				case EAST: { _sectorName = localize "STR_A3_WL_default_base_opfor"; };
				case RESISTANCE: { _sectorName = "INDEPENDENT Base"; };
				default { _sectorName = format ["%1 Base", _x getVariable "OWL_sectorSide"]; };
			};
		}
		else {
			_sectorName = _x call OWL_fnc_sectorLocationName;
		};
	}
	else {
		if (isLocalized _sectorName) then {
			_sectorName = localize _sectorName;
		};
	};
	
	// TEMPORARY CODE FOR TESTING
	private _marker = createMarkerLocal [format ["OWL_sectorNameMarker_%1", _forEachIndex], position _x];
	_marker setMarkerType "mil_dot";
	_marker setMarkerText _sectorName;
	
	_x setVariable ["OWL_sectorName", _sectorName];
	
} forEach OWL_allSectors;
