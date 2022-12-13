/*
	Function that gets the income value of a team.

	Returns 2 values
		[incomePerPlayer, bankFunds]
		_incomePerPlayer = Income each person recieves each minute update
		_bankFunds = Amount of money the bank will recieve for players missing.
*/

params ["_side"];

private _enemySide = (OWL_competingSides - [_side]) # 0;
private _sideCount = _side countSide allPlayers;
private _enemyCount = _enemySide countSide allPlayers;
if (_sideCount == 0 && _enemyCount == 0) exitWith {
	[0, 0];
};
// maybe use playersNumber side?

private _totalSectorIncome = 0;
{
	if ( (_x getVariable "OWL_sectorSide") == _side) then {
		_totalSectorIncome = _totalSectorIncome + (_x getVariable ["OWL_sectorIncome", 0]);
	};
} forEach OWL_allSectors;

// If a side is empty, bank gets all the money + avoids divide by 0 error.
if (_sideCount == 0) exitWith {[0, _totalSectorIncome * OWL_maxPlayersForSide];};

private _effectivePlayers = if (_enemyCount > _sideCount) then {_enemyCount} else {_sideCount};
private _incomePerPlayer = (_totalSectorIncome * _effectivePlayers) / _sideCount;
private _bankFunds = _totalSectorIncome * (OWL_maxPlayersForSide - _effectivePlayers);

[_incomePerPlayer, _bankFunds];