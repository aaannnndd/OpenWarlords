params ["_sideIdx", "_nextSector"];

// event handler for this variable on the client side will trigger all UI updates.
missionNamespace setVariable [format ["OWL_currentSector_%1", OWL_competingSides # _sideIdx], _nextSector, true];

/*
	TODO:

	update the sector lists.
	remote zone restrictions on this sector
	spawn AI in the zone if appropriate


*/