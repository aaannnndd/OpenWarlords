private _linked = [(OWL_competingSides # 0) call OWL_fnc_calculateLinkedSectors, (OWL_competingSides # 1) call OWL_fnc_calculateLinkedSectors];
private _unlocked = [ [], [] ];

{
	_sideIdx = (_x getVariable "OWL_sectorSide") find OWL_competingSides;
	_side = OWL_competingSide # _sideIdx;
	(_unlocked select _sideIdx) append _x;
} forEach OWL_allSectors;

missionNamespace setVariable [format ["OWL_linkedSectors_%1", (OWL_competingSides # 0)], (_linked # (OWL_competingSides # 0))];
missionNamespace setVariable [format ["OWL_linkedSectors_%1", (OWL_competingSides # 1)], (_linked # (OWL_competingSides # 1))];
missionNamespace setVariable [format ["OWL_capturedSectors_%1", (OWL_competingSides # 0)], (_unlocked # (OWL_competingSides # 0))];
missionNamespace setVariable [format ["OWL_capturedSectors_%1", (OWL_competingSides # 1)], (_unlocked # (OWL_competingSides # 1))];