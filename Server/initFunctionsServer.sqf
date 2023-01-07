
OWL_fnc_updateSectors = compileFinal preprocessFileLineNumbers "Server\updateSectors.sqf";
OWL_fnc_getIncomePayout = compileFinal preprocessFileLineNumbers "Server\getIncomePayout.sqf";
OWL_fnc_updateIncome = compileFinal preprocessFileLineNumbers "Server\updateIncome.sqf";
OWL_fnc_initMapAlterations = compileFinal preprocessFileLineNumbers "Server\initMapAlterations.sqf";
OWL_fnc_updateSpawnPoints = compileFinal preprocessFileLineNumbers "Server\updateSpawnPoints.sqf";
OWL_fnc_handleSectorSelected = compileFinal preprocessFileLineNumbers "Server\handleSectorSelected.sqf";

call compileFinal preprocessFileLineNumbers "Server\handleClientRequest.sqf";


OWL_fnc_popNonitializedPlayerId = {
	// Returns true if provided owner id was found and deleted from noninitialized ids array, otherwise false
	
	private _arrIndex = OWL_nonitializedPlayersIds find _this;
	if (_arrIndex != -1) exitWith {
		OWL_nonitializedPlayersIds deleteAt _arrIndex;
		true
	};
	false
};


OWL_fnc_tryInitNewWarlord = {
	params ["_owner", "_player"];
	
	if (_owner < 2) exitWith { ["Tried to initialize warlord data with owner parameter < 2. Params: " + str _this] call OWL_fnc_log; };
	if (isNull _player) exitWith { ["Tried to initialize warlord data with null player. Params: " + str _this] call OWL_fnc_log; };
	
	private _side = side group _player;
	if (_side == sideUnknown) exitWith { ["Players side is unknown. Perhaps player didn't finished initialization yet?"] call OWL_fnc_log; };
	if ( !(_side in OWL_playableSides) ) exitWith { [format ["Side (%1) of player (%2) is not in playable sides", _side, name _player]] call OWL_fnc_log; };
	
	isNil {	// Forcing the code to run in unscheduled to avoid edge cases
		
		// Exit if warlord data already exists for the given owner
		if (_owner in OWL_ownerToDataIndexMap) exitWith { [format ["Data already exists for the given owner ID (%1)", _owner]] call OWL_fnc_log; };
		
		// Initialize new warlord data
		private _newData = [_owner, _player, _side, OWL_startingCP];
		private _index = OWL_allWarlordsData pushBack _newData;
		OWL_ownerToDataIndexMap set [_owner, _index];
	};
};


OWL_fnc_tryDeleteWarlordData = {
	// Params: ownerID
	
	isNil {	// Forcing the code to run in unscheduled to avoid edge cases
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
	isNil {	// Forcing the code to run in unscheduled to avoid edge cases
		private _dataArrIndex = OWL_ownerToDataIndexMap get _this;
		if (!isNil "_dataArrIndex") then {
			_return = OWL_allWarlordsData # _dataArrIndex;
		};
	};
	_return
};

// Previous idea
/*OWL_fnc_clientRequestWarlordInit = {
	params ["_playerUnit"];
	
	private _owner = remoteExecutedOwner;
	if (isMultiplayer && {!isRemoteExecuted || {_owner < 2}}) exitWith {
		[format ["OWL_fnc_clientRequestWarlordInit function failed [isMultiplayer: %1, isRemoteExecuted: %2, _owner: %3]", isMultiplayer, isRemoteExecuted, _owner]] call OWL_fnc_log;
	};
};*/