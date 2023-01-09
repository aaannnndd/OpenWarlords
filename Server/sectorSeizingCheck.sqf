#include "..\defines.hpp"

_unitCache = [];

{
	if (!(side _x) in OWL_playableSides) then {
		continue;
	};

	if (vehicle _x != _x) then {
		_unitCache pushBackUnique (vehicle _x);
	} else {
		_unitCache pushBack _x;
	};

} forEach allUnits;

{
	private _sector = _x;
	private _inSectorArr = [];
	{
		private _unit = _x;
		if (_unit inAreaArray (_sector getVariable "OWL_sectorArea")) then {
			_inSectorArr pushBack _unit;
			_unitCache = _unitCache - [_unit];
		};
	} forEach _unitCache;

	if (count _inSectorArr > 0) then {
		[_inSectorArr, _sector] call OWL_fnc_handleUnitsInSector;
	};
} forEach OWL_allSectors;