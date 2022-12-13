params ["_side"];

private _linked = missionNamespace getVariable format ["OWL_linkedSectors_%1", _side];
private _attackable = [];

{
	_sector = _x;
	{
		if (typeOf _x == "Logic") then {
			if ( _sector != _x && (_x getVariable "OWL_sectorSide") != _side) then {
				_attackable pushBackUnique _x;
			};
		};
	} forEach synchronizedObjects _sector;
} forEach _linked;

_attackable;