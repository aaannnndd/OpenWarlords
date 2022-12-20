params ["_pilot", "_vehicleType", "_location", "_direction", "_type"];

switch {_type} do {
	case "airbourne":
	{
		_aircraft = createVehicle [_vehicleType, _position, [], 0, "FLY"]; 
		_aircraft setVelocityModelSpace [0,150,0]; 
		_pilot assignAsDriver _aircraft; 
		_pilot moveInDriver _aircraft;
	};
	case "fly-in":
	{
		_aircraft = createVehicle [_vehicleType, _position, [], 0, "FLY"]; 
	};
	case "ground":
	{
		_aircraft = createVehicle [_vehicleType, _position];
	};
};
