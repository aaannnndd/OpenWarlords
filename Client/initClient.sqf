
call compileFinal preprocessFileLineNumbers "Client\initFunctionsClient.sqf";

waitUntil { !isNull player };
waitUntil { missionNamespace getVariable ["OWL_ServerInitialized", false] };

/******************************************************
***********		Init Clientside Globals		***********
******************************************************/

player setVariable ["OWL_warlordSide", playerSide, true];

switch (playerSide) do {
	case WEST: {
		OWL_sectorIcon = "\A3\ui_f\data\map\markers\nato\b_installation.paa";
		OWL_sectorMarker = "b_installation";
		OWL_baseIcon = "\A3\ui_f\data\map\markers\nato\b_hq.paa";
		OWL_baseMarker = "b_hq";
	};
	case EAST: {
		OWL_sectorIcon = "\A3\ui_f\data\map\markers\nato\o_installation.paa";
		OWL_sectorMarker = "o_installation";
		OWL_baseIcon = "\A3\ui_f\data\map\markers\nato\o_hq.paa";
		OWL_baseMarker = "o_hq";
	};
	default {
		OWL_sectorIcon = "\A3\ui_f\data\map\markers\nato\n_installation.paa";
		OWL_sectorMarker = "n_installation";
		OWL_baseIcon = "\A3\ui_f\data\map\markers\nato\n_hq.paa";
		OWL_baseMarker = "n_hq";
	};
};

OWL_sectorColors = [
	[0, 0, 0, 0.8],
	[profileNamespace getVariable ["Map_BLUFOR_R", 0],
	 profileNamespace getVariable ["Map_BLUFOR_G", 0.3],
	 profileNamespace getVariable ["Map_BLUFOR_B", 0.6],
	 0.8],
	[profileNamespace getVariable ["Map_OPFOR_R", 0.5],
	 profileNamespace getVariable ["Map_OPFOR_G", 0],
	 profileNamespace getVariable ["Map_OPFOR_B", 0],
	 0.8],
	[profileNamespace getVariable ["Map_Independent_R", 0],
	 profileNamespace getVariable ["Map_Independent_G", 0.5],
	 profileNamespace getVariable ["Map_Independent_B", 0],
	 0.8]
];


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
	
	_x setVariable ["OWL_sectorName", _sectorName];
	
	// TEMPORARY CODE FOR TESTING
	private _marker = createMarkerLocal [format ["OWL_sectorMarkerName_%1", _forEachIndex], position _x];
	_marker setMarkerTypeLocal "mil_dot";
	_marker setMarkerTextLocal _sectorName;
	/////////////////////////////////////////////
	
	private _sectorArea = _x getVariable "OWL_sectorArea";
	private _sectorIsRectangle = _sectorArea # 4;
	private _markerSideColor = (_x getVariable "OWL_sectorSide") call OWL_fnc_sideToMarkerColor;
	
	private _markerBorderLine = format ["OWL_sectorMarkerBorderLine_%1", _forEachIndex];
	createMarkerLocal [_markerBorderLine, _sectorArea#0];
	_markerBorderLine setMarkerShapeLocal (["ELLIPSE", "RECTANGLE"] select _sectorIsRectangle);
	_markerBorderLine setMarkerBrushLocal "Border";	//(["SolidBorder", "Border"] select _sectorIsRectangle);
	_markerBorderLine setMarkerSizeLocal [_sectorArea#1, _sectorArea#2];
	_markerBorderLine setMarkerColorLocal _markerSideColor;
	_markerBorderLine setMarkerAlphaLocal 1;
	
	private _borderSize = (_x getVariable "OWL_sectorParam_borderSize");
	private _halfBorderSize = _borderSize / 2;
	private _borderMarkers = [];
	
	if (_sectorIsRectangle) then {
		for "_i" from 0 to 3 do {
			private ["_posX", "_posY"];
			
			if (_i % 2 == 0) then {
				_posX = (_sectorArea#0#0) + _halfBorderSize * (_i - 1);
				_posY = (_sectorArea#0#1) + ((_sectorArea#2) + _halfBorderSize) * (-_i + 1);
			}
			else {
				_posX = (_sectorArea#0#0) + ((_sectorArea#1) + _halfBorderSize) * (-_i + 2);
				_posY = (_sectorArea#0#1) + _halfBorderSize * (-_i + 2);
			};
			
			private _marker = format ["OWL_sectorMarkerBorder_%1_%2", _i + 1, _forEachIndex];
			createMarkerLocal [_marker, [_posX, _posY]];
			
			_marker setMarkerSizeLocal [(_sectorArea # (_i % 2 + 1)) + _halfBorderSize, _halfBorderSize];
			_marker setMarkerDirLocal (90 * (_i % 2));
			_marker setMarkerColorLocal _markerSideColor;
			_marker setMarkerAlphaLocal 0.35;
			_marker setMarkerBrushLocal "Solid";
			_marker setMarkerShapeLocal "RECTANGLE";
			
			_borderMarkers pushBack _marker;
		};
	}
	else {
		private _marker = format ["OWL_sectorMarkerBorder_1_%1", _forEachIndex];
		createMarkerLocal [_marker, _sectorArea#0];
		
		_marker setMarkerSizeLocal [_sectorArea#1 + _borderSize, _sectorArea#2 + _borderSize];
		_marker setMarkerDirLocal (_sectorArea#3);
		_marker setMarkerColorLocal _markerSideColor;
		_marker setMarkerAlphaLocal 0.35;
		_marker setMarkerBrushLocal "Solid";
		_marker setMarkerShapeLocal "ELLIPSE";
		
		_borderMarkers pushBack _marker;
	};
	
} forEach OWL_allSectors;


private _base = OWL_competingSides findIf { playerSide == _x; };
if (_base == -1) exitWith { ["Player doesn't belong to any competing side"] call OWL_fnc_log; };
_base = OWL_mainBases # _base;
player setPosATL getPosATL _base; // This should be moved to server side later because we don't want clients to execute setPos commands
