
// 0_0

OWL_allSectors = [];
{
	if (typeOf _x == "Logic" and {count synchronizedObjects _x > 0}) then {
		private _trigger = objNull;
		{
			if (typeOf _x != "Logic") then {
				_trigger = _x;
				break
			};
		} forEach synchronizedObjects _x;
		
		if (isNull _trigger) then {
			waitUntil {not isNull player};
			sleep 1;
			systemChat "trigger is null!";
			systemChat (str (synchronizedObjects _x));
		};

		_x setVariable ["OWL_sectorArea", triggerArea _trigger];
		OWL_allSectors pushBack _x;
		deleteVehicle _trigger;
	};
} forEach (entities "Logic");

setGroupIconsVisible [true,false];
setGroupIconsSelectable true;

if (side group player == EAST) then {
	OWL_sectorIcon = "\A3\ui_f\data\map\markers\nato\o_installation.paa";
	OWL_sectorMarker = "o_installation";
	OWL_baseIcon = "\A3\ui_f\data\map\markers\nato\o_hq.paa";
	OWL_baseMarker = "o_hq";
} else {
	OWL_sectorIcon = "\A3\ui_f\data\map\markers\nato\b_installation.paa";
	OWL_sectorMarker = "b_installation";
	OWL_baseIcon = "\A3\ui_f\data\map\markers\nato\b_hq.paa";
	OWL_baseMarker = "b_hq";
};

OWL_sectorColors = [
	[profileNamespace getVariable ["Map_Independent_R", 0], profileNamespace getVariable ["Map_Independent_G", 1], profileNamespace getVariable ["Map_Independent_B", 1], 0.8],
	[profileNamespace getVariable ["Map_OPFOR_R", 0], profileNamespace getVariable ["Map_OPFOR_G", 1], profileNamespace getVariable ["Map_OPFOR_B", 1], 0.8],
	[profileNamespace getVariable ["Map_BLUFOR_R", 0], profileNamespace getVariable ["Map_BLUFOR_G", 1], profileNamespace getVariable ["Map_BLUFOR_B", 1], 0.8]
];

{
	_sector = _x;
	_sideIdx = [RESISTANCE, EAST, WEST] find (_sector getVariable "OWL_sectorSide");
	private _pointerGrp = createGroup CIVILIAN;
	private _pointerIcon = _pointerGrp createUnit ["Logic", getPosATL _sector, [], 0, "NONE"];
	_pointerIcon enableSimulationGlobal false;
	_pointerIcon attachTo [_sector, [0,0,0]];
	_sector enableSimulationGlobal false;
	_pointerGrp addGroupIcon [OWL_sectorMarker, [0,0]];
	_pointerGrp setGroupIconParams [OWL_sectorColors # _sideIdx, "", 1, TRUE];
	
	_triggerArea = _sector getVariable "OWL_sectorArea";
	_marker = format ["OWL_sectorMarker_%1", _forEachIndex];
	createMarkerLocal [_marker, getPosASL _sector];
	_marker setMarkerShapeLocal (["ELLIPSE", "RECTANGLE"] select (_triggerArea#3));
	_marker setMarkerBrushLocal "Border";
	_marker setMarkerSizeLocal [_triggerArea#0, _triggerArea#1];
	_marker setMarkerColorLocal ((["colorIndependent", "colorOPFOR", "colorBLUFOR"]) # _sideIdx);

	_mrkrNameLock1 = format ["OWL_sectorMrkrLock1_%1", _forEachIndex];
	_mrkrNameLock2 = format ["OWL_sectorMrkrLock2_%1", _forEachIndex];
	_mrkrNameLock3 = format ["OWL_sectorMrkrLock3_%1", _forEachIndex];
	_mrkrNameLock4 = format ["OWL_sectorMrkrLock4_%1", _forEachIndex];
	_pos = position _sector;
	_relPosArr = [[1, 1, 0, 0, 1], [1, -1, 90, 1, 0], [-1, -1, 0, 0, -1], [-1, 1, 90, -1, 0]];
	{
		_relPos = _relPosArr # _forEachIndex;
		_trgSize = ((_sector getVariable ["OWL_sectorArea", [200]]) # 0) / 2;
		_borderHalf = (_sector getVariable ["OWL_sectorBorderSize", 200]) / 2;
		_null = createMarkerLocal [_x, [(_pos # 0) + (_trgSize * (_relPos # 3)) + (_borderHalf * (_relPos # 0)), (_pos # 1) + (_trgSize * (_relPos # 4)) + (_borderHalf * (_relPos # 1))]];
		_x setMarkerShapeLocal "RECTANGLE";
		_x setMarkerBrushLocal "Solid";
		_x setMarkerDirLocal (_relPos # 2);
		_x setMarkerSizeLocal [(_trgSize) + _borderHalf, _borderHalf];
		_x setMarkerColorLocal ((["colorOPFOR", "colorBLUFOR", "colorIndependent"]) # ([EAST, WEST, RESISTANCE] find (_sector getVariable "OWL_sectorSide")));
		_x setMarkerAlphaLocal 0.35;
		if (_sector getVariable "OWL_sectorSide" == side player) then {
			_x setMarkerAlphaLocal 0;
		};
	} forEach [_mrkrNameLock1, _mrkrNameLock2, _mrkrNameLock3, _mrkrNameLock4];
	_x setVariable ["OWL_sectorLockMrkrs", [_mrkrNameLock1, _mrkrNameLock2, _mrkrNameLock3, _mrkrNameLock4]];

} forEach OWL_allSectors;