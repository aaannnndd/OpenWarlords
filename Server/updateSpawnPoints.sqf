// Getting the logic hammered out here. Can later chain this into 'onSectorSideChange' hook
{
	_sector = _x;
	_respawnMarker = _sector getVariable ["OWL_respawnMarker", ""];
	_side = _sector getVariable "OWL_sectorSide";
	if (_respawnMarker == "") then {
		_respawnMarker = createMarker [format ["respawn_%1_%2", _side, _forEachIndex], position _sector];
		_sector setVariable ["OWL_respawnMarker", _respawnMarker];
	};
	
	if ( !(str _side in _respawnMarker ) ) then {
		deleteMarker _respawnMarker;
		_respawnMarker = createMarker [format ["respawn_%1_%2", _side, _forEachIndex], position _sector];
		_sector setVariable ["OWL_respawnMarker", _respawnMarker];
	};
} forEach OWL_allSectors;