{
	_sector = _x;
	_assets = [];
	_infantry = [];
	{
		_obj = _x;
		_grp = group _obj;

		if (typeOf _obj != "Logic") then {
			if (_obj isKindOf "Man") then {
				_squad = [];
				{
					_squad pushBack [typeOf _x, position _x, direction _x, _grp];
					deleteVehicle _x;
				} forEach units _obj;
				_infantry pushBack _squad;
			};
			
			if (_obj isKindOf "Vehicle") then {
				_veh = vehicle _obj;
				_grp = group effectiveCommander _obj;
				_crew = [];
				{_crew pushBack (typeOf _x);} forEach crew _veh;
				_assets pushBack [typeOf _veh, position _veh, direction _veh, _grp, _crew];
				{_veh deleteVehicleCrew _x} forEach crew _veh;
				deleteVehicle _veh;
			};
		};
	} forEach synchronizedObjects _sector;

	_sector setVariable ["OWL_sectorAssets", _assets + _infantry];
} forEach OWL_allSectors;