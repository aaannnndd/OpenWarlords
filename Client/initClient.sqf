
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
		OWL_sectorIconMarker = "b_installation";
		OWL_baseIcon = "\A3\ui_f\data\map\markers\nato\b_hq.paa";
		OWL_baseIconMarker = "b_hq";
	};
	case EAST: {
		OWL_sectorIcon = "\A3\ui_f\data\map\markers\nato\o_installation.paa";
		OWL_sectorIconMarker = "o_installation";
		OWL_baseIcon = "\A3\ui_f\data\map\markers\nato\o_hq.paa";
		OWL_baseIconMarker = "o_hq";
	};
	default {
		OWL_sectorIcon = "\A3\ui_f\data\map\markers\nato\n_installation.paa";
		OWL_sectorIconMarker = "n_installation";
		OWL_baseIcon = "\A3\ui_f\data\map\markers\nato\n_hq.paa";
		OWL_baseIconMarker = "n_hq";
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
	
	private _sectorArea = _x getVariable "OWL_sectorArea";
	private _sectorIsRectangle = _sectorArea # 4;
	private _markerSideColor = (_x getVariable "OWL_sectorSide") call OWL_fnc_sideToMarkerColor;
	
	private _markerIcon = format ["OWL_sectorMarkerIcon_%1", _forEachIndex];
	createMarkerLocal [_markerIcon, _sectorArea#0];
	_markerIcon setMarkerTypeLocal ([OWL_sectorIconMarker, OWL_baseIconMarker] select (_x in OWL_mainBases));
	_markerIcon setMarkerSizeLocal [1, 1];
	_markerIcon setMarkerColorLocal _markerSideColor;
	_markerIcon setMarkerAlphaLocal 1;
	_x setVariable ["OWL_sectorMarkerIcon", _markerIcon];
	
	private _markerInnerLine = format ["OWL_sectorMarkerInnerLine_%1", _forEachIndex];
	createMarkerLocal [_markerInnerLine, _sectorArea#0];
	_markerInnerLine setMarkerShapeLocal (["ELLIPSE", "RECTANGLE"] select _sectorIsRectangle);
	_markerInnerLine setMarkerBrushLocal "Border";	//(["SolidBorder", "Border"] select _sectorIsRectangle);
	_markerInnerLine setMarkerSizeLocal [_sectorArea#1, _sectorArea#2];
	_markerInnerLine setMarkerColorLocal _markerSideColor;
	_markerInnerLine setMarkerAlphaLocal 1;
	_x setVariable ["OWL_sectorMarkerInnerLine", _markerInnerLine];
	
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
	
	_x setVariable ["OWL_sectorBorderMarkers", _borderMarkers];
	
} forEach OWL_allSectors;


/******************************************************
***********		Check the game state		***********
******************************************************/

"BIS_WL_Initialized_WEST" call OWL_fnc_eventAnnouncer;

// If no sector to attack, then we're in voting phase!
if (isNull (missionNamespace getVariable [format ["OWL_currentSector_%1", playerSide], objNull])) then {
	call OWL_fnc_voteNewSectorPrompt;
};

