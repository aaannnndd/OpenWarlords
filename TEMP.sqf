
if (!hasInterface) exitWith {};
waitUntil { !isNull player };
waitUntil { missionNamespace getVariable ["OWL_ServerInitialized", false] };

[] spawn {
	while {true} do {
		{
			if (player inArea (_x getVariable "OWL_sectorArea")) then {
				hintSilent format ["Inside (%1)", _x getVariable "OWL_sectorName"];
				sleep (((count OWL_allSectors - 1) - _forEachIndex) / (count OWL_allSectors - 1));
				break;
			}
			else {
				private _borderArea = +(_x getVariable "OWL_sectorArea");
				_borderArea set [1, _borderArea#1 + (_x getVariable "OWL_sectorParam_borderSize")];
				_borderArea set [2, _borderArea#2 + (_x getVariable "OWL_sectorParam_borderSize")];
				if (player inArea _borderArea) then {
					hintSilent format ["Inside border of (%1)", _x getVariable "OWL_sectorName"];
					sleep (((count OWL_allSectors - 1) - _forEachIndex) / (count OWL_allSectors - 1));
					break;
				}
				else {
					if (_forEachIndex + 1 == count OWL_allSectors) then {
						hintSilent "Outside of any sector";
					};
				};
			};
			
			sleep 0.02;
		} forEach OWL_allSectors;
	};
};

waitUntil {!isNull (findDisplay 12 displayCtrl 51)};
systemChat "Adding draw EH on map";

OWL_CursorIsOverSector = false;
(findDisplay 12 displayCtrl 51) ctrlAddEventHandler ["Draw", {	
	{
		if (((_this#0) ctrlMapWorldToScreen ((_x getVariable "OWL_sectorArea") # 0)) distance2D getMousePosition < 0.02) then {
			if (!OWL_CursorIsOverSector) then {
				(_this#0) ctrlMapCursor ["Track", "HC_overEnemy"];
				OWL_CursorIsOverSector = true;
				systemChat format ["Cursor is over (%1) sector", _x getVariable "OWL_sectorName"];
			};
			
			(_this#0) drawIcon [
				"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
				[0.75, 0.75, 0.75, 1],
				(_x getVariable "OWL_sectorArea") # 0,
				40,
				40,
				(time * 20) % 360,
				"",
				1,
				0.1,
				"EtelkaNarrowMediumPro",
				"right"
			];
			
			break;
		};
		
		if (_forEachIndex + 1 == count OWL_allSectors) then { OWL_CursorIsOverSector = false; };
	} forEach OWL_allSectors;
	
	if (!OWL_CursorIsOverSector) then {
		(_this#0) ctrlMapCursor ["Track", ""];
	};
}];

/*
{
	private _marker = format ["OWL_sectorMarkerNameTEST_%1", _forEachIndex];
	createMarkerLocal [_marker, (_x getVariable "OWL_sectorArea") # 0];
	_marker setMarkerTypeLocal "mil_dot";
	_marker setMarkerTextLocal _sectorName;
} forEach OWL_allSectors;
*/

/*
setGroupIconsVisible [true,false];
setGroupIconsSelectable true;

{
	_sector = _x;
	_sideIdx = _sector getVariable "OWL_sectorParam_side";
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
	_marker setMarkerColorLocal ((["ColorBlack", "ColorWEST", "ColorEAST", "ColorGUER"]) # _sideIdx);

	_mrkrNameLock1 = format ["OWL_sectorMrkrLock1_%1", _forEachIndex];
	_mrkrNameLock2 = format ["OWL_sectorMrkrLock2_%1", _forEachIndex];
	_mrkrNameLock3 = format ["OWL_sectorMrkrLock3_%1", _forEachIndex];
	_mrkrNameLock4 = format ["OWL_sectorMrkrLock4_%1", _forEachIndex];
	_pos = position _sector;
	_relPosArr = [[1, 1, 0, 0, 1], [1, -1, 90, 1, 0], [-1, -1, 0, 0, -1], [-1, 1, 90, -1, 0]];
	{
		_relPos = _relPosArr # _forEachIndex;
		_trgSize = ((_sector getVariable ["OWL_sectorArea", [200]]) # 0);
		_borderHalf = (_sector getVariable ["OWL_sectorParam_borderSize", 200]) / 2;
		_null = createMarkerLocal [_x, [(_pos # 0) + (_trgSize * (_relPos # 3)) + (_borderHalf * (_relPos # 0)), (_pos # 1) + (_trgSize * (_relPos # 4)) + (_borderHalf * (_relPos # 1))]];
		_x setMarkerShapeLocal "RECTANGLE";
		_x setMarkerBrushLocal "Solid";
		_x setMarkerDirLocal (_relPos # 2);
		_x setMarkerSizeLocal [(_trgSize) + _borderHalf, _borderHalf];
		_x setMarkerColorLocal ((["ColorBlack", "ColorWEST", "ColorEAST", "ColorGUER"]) # _sideIdx);
		_x setMarkerAlphaLocal 0.35;
		if (_sector getVariable "OWL_sectorSide" == side player) then {
			_x setMarkerAlphaLocal 0;
		};
	} forEach [_mrkrNameLock1, _mrkrNameLock2, _mrkrNameLock3, _mrkrNameLock4];
	_x setVariable ["OWL_sectorLockMrkrs", [_mrkrNameLock1, _mrkrNameLock2, _mrkrNameLock3, _mrkrNameLock4]];

} forEach OWL_allSectors;
*/
