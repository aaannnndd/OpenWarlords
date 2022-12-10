#include "..\defines.hpp"

// Remove playable units in SP game
if (not isMultiplayer) then {
	waitUntil { not isNull player };
	{
		if (player != _x) then { deleteVehicle _x; };
	} forEach switchableUnits;
};
