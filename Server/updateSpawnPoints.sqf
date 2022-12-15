// Getting the logic hammered out here. Can later chain this into 'onSectorSideChange' hook

{
	_sector = _x;
	_respawnId = _sector getVariable ["OWL_respawnId", []];
	_side = _sector getVariable "OWL_sectorSide";
	_marker = createMarker [format ["respawn_%1_%2", _side, netId _sector], position _sector];

	if ( count _respawnId == 0 ) then {
		_respawnId = [_side, _marker, _sector getVariable "OWL_sectorName"] call BIS_fnc_addRespawnPosition;
	} else {
		if ( _sector getVariable "OWL_sectorSide" != (_respawnId # 0) ) then {
			_respawnId call BIS_fnc_removeRespawnPosition;
			_respawnId = [_side, _marker, _sector getVariable "OWL_sectorName"] call BIS_fnc_addRespawnPosition;
			_sector setVariable ["OWL_respawnId", _respawnId];
		};
	};
} forEach OWL_allSectors;