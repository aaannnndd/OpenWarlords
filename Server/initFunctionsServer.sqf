
OWL_fnc_getIncomePayout = compileFinal preprocessFileLineNumbers "Server\getIncomePayout.sqf";
OWL_fnc_updateIncome = compileFinal preprocessFileLineNumbers "Server\updateIncome.sqf";
OWL_fnc_updateSpawnPoints = compileFinal preprocessFileLineNumbers "Server\updateSpawnPoints.sqf";
OWL_fnc_handleSectorSelected = compileFinal preprocessFileLineNumbers "Server\handleSectorSelected.sqf";


OWL_fnc_tryRemoveFromNonHandshakedClients = {
	// Returns true if client with provided UID was found and removed from OWL_nonHandshakedClients array
	// Params: UID - string
	
	private _found = false;
	// Forcing the code to run in unscheduled to avoid edge cases
	isNil {
		private _i = 0;
		while {_i < count OWL_nonHandshakedClients} do {
			if ((OWL_nonHandshakedClients # _i # 0) isEqualTo _this) then {
				OWL_nonHandshakedClients deleteAt _i;
				_found = true;
			}
			else {
				_i = _i + 1;
			};
		};
	};
	_found
};


OWL_fnc_tryInitNewWarlord = {
	params ["_owner", "_player"];
	
	private _newWarlordInitialized = false;
	private _side = side group _player;
	
	if ( !(_side in OWL_playableSides) ) exitWith {
		[format ["Could not initialize new warlord (%1) because their side (%2) is not in playable sides", name _player, _side]] call OWL_fnc_log;
		false
	};
	
	// Forcing the code to run in unscheduled to avoid edge cases
	isNil {
		// Exit if warlord data already exists for the given owner
		if (_owner in OWL_ownerToDataIndexMap) exitWith { [format ["Data already exists for the given owner ID (%1)", _owner]] call OWL_fnc_log; };
		
		// Initialize new warlord data
		private _newData = [_owner, _player, _side, OWL_startingCP];
		
		private _index = OWL_allWarlordsData pushBack _newData;
		OWL_ownerToDataIndexMap set [_owner, _index];
		_newWarlordInitialized = true;
	};
	_newWarlordInitialized
};


OWL_fnc_tryDeleteWarlordData = {
	// Params: ownerID
	
	// Forcing the code to run in unscheduled to avoid edge cases
	isNil {
		private _dataArrIndex = OWL_ownerToDataIndexMap get _this;
		
		if (!isNil "_dataArrIndex") then {
			OWL_ownerToDataIndexMap deleteAt _this;
			
			// To delete an element from warlords data array we creating a shallow copy of it and modifying the copy,
			// instead of modifying the original array. This way if there's forEach loop iterating through original array during deletion
			// we won't shift elements in it, potentially causing forEach loop to skip an element.
			// See https://community.bistudio.com/wiki/forEach#Notes
			
			private _newDataArray = OWL_allWarlordsData + [];
			_newDataArray deleteAt _dataArrIndex;
			OWL_allWarlordsData = _newDataArray;
			
			// Update indexes of affected array elements in hashmap
			for "_i" from _dataArrIndex to (count OWL_allWarlordsData - 1) do {
				OWL_ownerToDataIndexMap set [OWL_allWarlordsData # _i # 0, _i];
			};
		};
	};
};


OWL_fnc_getWarlordDataByOwnerId = {
	// Params: ownerID
	
	private _return = [];
	// Forcing the code to run in unscheduled to avoid edge cases
	isNil {
		private _dataArrIndex = OWL_ownerToDataIndexMap get _this;
		if (!isNil "_dataArrIndex") then {
			_return = OWL_allWarlordsData # _dataArrIndex;
		};
	};
	_return
};
