/*
	Updates the income of all players and the bank once every minute.

	Variables Modified:
		OWL_disconnectedFunds
		OWL_bankValue_EAST/WEST/RESISTANCE
		player->OWL_commandPoints
*/

// Distribute command points for each side + add unused to the bank.
{
	private _side = _x;
	private _incomeInfo = _side call OWL_fnc_getIncomePayout;
	_incomeInfo params ["_incomePerPlayer", "_bankFunds"];

	{
		_x setVariable ["OWL_commandPoints", _incomePerPlayer, owner _x];
	} forEach (OWL_allWarlords select {side _x == _side});

	missionNamespace setVariable [format ["OWL_bankValue_%1", _side], _bankFunds + (missionNamespace getVariable [format ["OWL_bankValue_%1", _side], 0]), TRUE];
} forEach OWL_competingSides;

/* Check disconected players, if they've been gone for a certain period of time add their command points to the bank.
{
	_x params ["_transactionID", "_side", "_amount", "_timestamp"];
	if (_timestamp <= GET_TIME) then {
		missionNamespace setVariable [format ["OWL_bankValue_%1", _side], _amount + (missionNamespace getVariable [format ["OWL_bankValue_%1", _side], 0]), TRUE];
		OWL_disconnectedFunds = OWL_disconnectedFunds - [_x];
	};
} forEach OWL_disconnectedFunds;*/

{
	_y params ["_timeStamp", "_side", "_funds"];
	if (_timeStamp > GET_TIME) then {
		missionNamespace setVariable [format ["OWL_bankValue_%1", _side], _funds + (missionNamespace getVariable [format ["OWL_bankValue_%1", _side], 0]), TRUE];
		OWL_persistentWarlordsData deleteAt _x;
		/* If we hold other persistent data other than funds.
		_y set [2, 0];
		OWL_persistentWarlordsData set [_x, _y];
		*/
	};
} forEach OWL_persistentWarlordsData;