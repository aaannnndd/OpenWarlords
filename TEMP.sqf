
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
		OWL_allSectors pushBack [_x, _trigger];
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
	_x params ["_sector", "_trigger"];
	private _pointerGrp = createGroup CIVILIAN;
	private _pointerIcon = _pointerGrp createUnit ["Logic", getPosATL _sector, [], 0, "NONE"];
	_pointerIcon enableSimulationGlobal false;
	_pointerIcon attachTo [_sector, [0,0,0]];
	_sector enableSimulationGlobal false;
	_pointerGrp addGroupIcon [OWL_sectorMarker, [0,0]];
	_pointerGrp setGroupIconParams [OWL_sectorColors # (_sector getVariable "OWL_sectorSide"), "", 1, TRUE];
	
	private _triggerArea = triggerArea _trigger;
	_marker = format ["OWL_sectorMarker_%1", _forEachIndex];
	createMarkerLocal [_marker, getPosASL _sector];
	_marker setMarkerShapeLocal (["ELLIPSE", "RECTANGLE"] select (_triggerArea#3));
	_marker setMarkerBrushLocal "Border";
	_marker setMarkerSizeLocal [_triggerArea#0, _triggerArea#1];
	_marker setMarkerColorLocal ((["colorIndependent", "colorOPFOR", "colorBLUFOR"]) # (_sector getVariable "OWL_sectorSide"));
} forEach OWL_allSectors;
