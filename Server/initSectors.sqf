
// I guess we should split this to server side and client side

OWL_allSectors = [];

{
	private _syncedObjects = synchronizedObjects _x;
	// We do typeOf check because entities command also returns entities deriving from the given type
	if (typeOf _x == "Logic" && {count _syncedObjects > 0}) then {	
		private _trigger = _syncedObjects findIf { typeOf _x == "EmptyDetector" };
		if (_trigger == -1) then { continue };
		_trigger = _syncedObjects # _trigger;
		private _triggerPos = getPosASL _trigger;
		private _triggerArea = triggerArea _trigger;
		deleteVehicle _trigger;
		
		_triggerPos set [2, 0];
		_x setPosATL _triggerPos;
		_x setVariable ["OWL_sectorPos", _triggerPos, true];
		_x setVariable ["OWL_sectorArea", triggerArea _trigger, true];
		_x setVariable ["OWL_sectorSide",
			[sideEmpty, OWL_competingSides#0, OWL_competingSides#1, OWL_defendingSide] # (_x getVariable ["OWL_sectorParam_side", 0]),
		true];
		
		private _sectorIncome = _x getVariable ["OWL_sectorParam_income", -1];
		if (_sectorIncome < 0) then {
			// Use weird formula to calculate sector income based on its size
			_sectorIncome = (round ((_triggerArea#0 + _triggerArea#1) / 100)) * 5;
		};
		
		_x setVariable ["OWL_sectorIncome", _sectorIncome, true];
		_x setVariable ["OWL_sectorFastTravelEnabled", _x getVariable ["OWL_sectorParam_fastTravelEnabled", true], true];
		
		OWL_allSectors pushBack _x;
	};
} forEach (entities "Logic");
