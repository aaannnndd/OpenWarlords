params ["_side"];

private _mainBase = missionNamespace getVariable (format ["OWL_mainBase_%1", _side]);

OWL_fnc_buildLinks = {
	params ["_chain"];

	private _sector = _chain select (count _chain - 1);
	{
		if (! (_x in _chain)) then {
			_chain pushBack _x;
			[_chain] call OWL_fnc_buildLinks;
		};
	} forEach synchronizedObjects _sector;
};

private _chain = [_mainBase];
[_chain] call OWL_fnc_buildLinks;

// _chain now a list of sectors that are attached to the main base.
_chain;






























/*
This was my trial run until we can get the sectors working.
TEST = [ [1,2], [0,3], [0,4], [1,5], [2,6], [3,7], [4] ];
//			0		1	   2      3      4      5     6
_chain = [0];
OWL_fnc_getNextLink = { 
 params ["_chain"];
 _node = _chain select ((count _chain) - 1);
 {
  if ( !(_x in _chain) ) then {
   _chain pushBack _x;
   [_chain] call OWL_fnc_getNextLink;
  }; 
 } forEach (TEST # _node);
};

[_chain] call OWL_fnc_getNextLink;
_chain;

// [0,1,3,5,7,2,4,6]*/