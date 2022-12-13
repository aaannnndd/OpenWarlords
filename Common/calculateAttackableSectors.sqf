params ["_side"];

private _linked = missionNamespace getVariable format ["OWL_linkedSectors_%1", _side];
private _attackable = [];

{
	_sector = _x;
	{
		if (_sector != _x && _x getVariable "OWL_sectorSide" != _side) then {
			_attackable pushBackUnique _x;
		};
	} forEach _sector synchronizedObjects;
} forEach _linked;

_attackable;