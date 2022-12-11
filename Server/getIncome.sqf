params ["_side"];

_totalSectorIncome = 0;

{
	if (_x getVariable ["OWL_sectorSide"] == _side) then {_
		_totalSectorIncome = _totalSectorIncome + (_x getVariable ["OWL_sectorIncome", 0]);
	};
} forEach OWL_allSectors;

