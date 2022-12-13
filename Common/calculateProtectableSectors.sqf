params ["_side"];

// sector must be connected to main base.
_linkedSectors = missionNamespace getVariable [format ["OWL_linkedSectors_%1", _side], []];
_protectable = [];

{
	_sector = _x;
	_valid = true;

	// Sector can't have adjacent enemy sectors.
	{
		if (typeOf _x == "Logic" &&
			_x getVariable "OWL_sectorSide" != _side) then {
			_valid = false;
		};
	} forEach synchronizedObjects _x;

	// Sector cannot be under attack.
	if ( _sector == missionNamespace getVariable format ["OWL_currentSector_%1", ( OWL_competingSides - [_side]) # 0] ) then {_valid = false;};
	// Sector must be owned by the side
	if ( _sector getVariable "OWL_sectorSide" != _side) then {_valid = false;};
	// Sector cannot already be protected
	if ( _sector getVariable "OWL_sectorProtected" ) then {_valid = false;};

	if ( _valid) then {
		_protectable pushBack _sector;
	};

} forEach _linkedSectors;

_protectable;