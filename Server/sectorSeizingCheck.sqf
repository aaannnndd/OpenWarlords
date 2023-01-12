#include "..\defines.hpp"

/* Variable Init will go somewhere else */

_unitCache = [];

{
	_zrArea = +(_x getVariable "OWL_sectorArea");
	_border = _x getVariable "OWL_sectorParam_borderSize";
	_zrArea set [1, (_zrArea # 1) + _border];
	_zrArea set [2, (_zrArea # 2) + _border];
	_x setVariable ["OWL_sectorRestrictionArea", _zrArea];
} forEach OWL_allSectors;

if (isNil {OWL_inZoneRestrictionArr}) then {
	OWL_inZoneRestrictionArr = createHashMap;
};

/* Actual Code */

// Remove anything irrelevant.
{
	if (!((side _x) in OWL_playableSides)) then {
		continue;
	};

	_unitCache pushBack _x;

} forEach allUnits;

OWL_fnc_handleUnitsInSector = {
	systemChat str _this;
};

// send when a player is in a zone, or when they leave a zone (_newSector == objNull)
OWL_fnc_updateZoneRestriction = {
	systemChat str _this;
	params ["_player", "_newSector"];

	// Weird edge case where they die and respawn, leaving a corpse behind.
	if (!isPlayer _player) exitWith {
		OWL_inZoneRestrictionArr deleteAt (netId _player);
		-1 remoteExec ["OWL_inRestrictedArea", netId _player];
	};

	// Player no longer in a sector, remote from thing and tell client.
	if (isNull _newSector) exitWith {
		OWL_inZoneRestrictionArr deleteAt (netId _player);
		-1 remoteExec ["OWL_inRestrictedArea", netId _player];
	};

	_oldSectorInfo = OWL_inZoneRestrictionArr get (netId _player);
	_oldSector = objNull;
	_zrTimestamp = -1;

	// Get old sector player was in.
	if (!isNil {_oldSectorInfo}) then {
		_oldSector = _oldSectorInfo # 0;
		_zrTimestamp = _oldSectorInfo # 1;
	};

	// If the old sector is same as new, check timer until they die.
	if (_oldSector == _newSector) exitWith {
		if (_zrTimestamp < serverTime) then {
			_player setDamage 1;
			OWL_inZoneRestrictionArr deleteAt (netId _player);
			-1 remoteExec ["OWL_inRestrictedArea", owner _player];
		};
	};
	
	// If the sector isn't, update with new timestamp.
	OWL_inZoneRestrictionArr set [(owner _player), [_newSector, (serverTime + 30)]];
	(serverTime + 30) remoteExec ["OWL_inRestrictedArea", owner _player];
};

// Loop through all sectors and prune the unitCache as we go.
{
	private _sector = _x;
	private _inSectorArr = [];
	{
		private _unit = _x;

		// Check if players are in the sector. Since players can only be in one sector at a time we can remove them as we find them.
		if (_unit inArea (_sector getVariable "OWL_sectorArea")) then {
			_inSectorArr pushBack _unit;
			if (isPlayer _unit && (side _unit != _sector getVariable "OWL_sectorSide")) then {
				[_unit, _sector] call OWL_fnc_updateZoneRestriction;
			};
			_unitCache = _unitCache - [_unit];
		} else {
			if ( isPlayer _unit && { (side _unit != _sector getVariable "OWL_sectorSide") && {_unit inArea (_sector getVariable "OWL_sectorRestrictionArea")} }) then {
				[_unit, _sector] call OWL_fnc_updateZoneRestriction;
				_unitCache = _unitCache - [_unit];
			};
		};
	} forEach _unitCache;

	if (count _inSectorArr > 0) then {
		[_inSectorArr, _sector] call OWL_fnc_handleUnitsInSector;
	};
} forEach OWL_allSectors;

// unitCache excludes dead units, so check if they're dead.
// **Might be easier to assign a 'player setVariable' to handle the dead player
//   Automatically.
{
	_player = _y # 0;
	if (_player in _unitCache || !isPlayer _player) then {
		[_player, objNull] call OWL_fnc_updateZoneRestriction;
	};
} forEach OWL_inZoneRestrictionArr;