
/******************************************************
***********		Init Clientside Functions	***********
******************************************************/

OWL_fnc_handleServerUpdate = compileFinal preprocessFileLineNumbers "Client\handleServerUpdate.sqf";
OWL_fnc_sectorLocationName = compileFinal preprocessFileLineNumbers "Client\sectorLocationName.sqf";


waitUntil { !isNull player };
waitUntil { missionNamespace getVariable ["OWL_ServerInitialized", false] };

/******************************************************
***********		Init Sectors Serverside		***********
******************************************************/

{
	private _sectorName = _x getVariable ["OWL_sectorParam_name", ""];
	if ( _sectorName == "" || { _x getVariable ["OWL_sectorParam_useLocationName", false] } ) then {
		_sectorName = _x call OWL_fnc_sectorLocationName;
	}
	else {
		if (isLocalized _sectorName) then {
			_sectorName = localize _sectorName;
		};
	};
	
	// TEMPORARY CODE FOR TESTING
	if (!isNil "OWL_mainBase_WEST" && {_x == OWL_mainBase_WEST}) then {
		_sectorName = localize "STR_A3_WL_default_base_blufor";
	};
	if (!isNil "OWL_mainBase_EAST" && {_x == OWL_mainBase_EAST}) then {
		_sectorName = localize "STR_A3_WL_default_base_opfor";
	};
	if (!isNil "OWL_mainBase_RESISTANCE" && {_x == OWL_mainBase_RESISTANCE}) then {
		_sectorName = "INDEPENDENT Base";
	};
	private _marker = createMarkerLocal [format ["OWL_sectorNameMarker_%1", _forEachIndex], position _x];
	_marker setMarkerType "mil_dot";
	_marker setMarkerText _sectorName;
	
	_x setVariable ["OWL_sectorName", _sectorName];
	
} forEach OWL_allSectors;
