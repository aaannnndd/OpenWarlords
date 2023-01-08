#include "..\defines.hpp"

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
	params ["_owner", "_uid", "_player"];
	
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
		
		// Creating new warlord data
		private _newData = [];
		SET_WARLORD_OWNER_ID(_newData, _owner);
		SET_WARLORD_PLAYER(_newData, _player);
		SET_WARLORD_SIDE(_newData, _side);
		private _takenFunds = OWL_StartingFunds;
		
		// Loading up persistent data save
		if (OWL_persistentDataEnabled) then {
			private _persistentWarlordData = OWL_persistentWarlordsData get _uid;
			if (!isNil "_persistentWarlordData") then {
				_persistentWarlordData params ["_dsTime", "_savedSide", "_savedFunds"];
				if (_side == _savedSide) then {
					_takenFunds = _savedFunds;
					[format ["Loaded saved warlord data of %1", name _player]] call OWL_fnc_log;
				}
				else {
					[format ["Deleted previous saved warlord data of %1", name _player]] call OWL_fnc_log;
				};
				OWL_persistentWarlordsData deleteAt _uid;
			};
		};
		
		SET_WARLORD_FUNDS(_newData, _takenFunds);
		
		private _index = OWL_allWarlordsData pushBack _newData;
		OWL_ownerToDataIndexMap set [_owner, _index];
		_newWarlordInitialized = true;
	};
	_newWarlordInitialized
};


OWL_fnc_tryDeinitWarlord = {
	// Params:
	// 0: ownerID - number
	// 1: UID - string (optional, add it only if you want to create a persistent save for data of the deinitialized warlord) 
	params ["_owner", ["_uid", "", [""]]];
	
	// Forcing the code to run in unscheduled to avoid edge cases
	isNil {
		private _dataArrIndex = OWL_ownerToDataIndexMap get _owner;
		
		if (!isNil "_dataArrIndex") then {
			OWL_ownerToDataIndexMap deleteAt _owner;
			
			if (OWL_persistentDataEnabled && {_uid != ""}) then {
				private _warlordData = OWL_allWarlordsData # _dataArrIndex;
				[format ["Saving warlord data of %1", name GET_WARLORD_PLAYER(_warlordData)]] call OWL_fnc_log;
				private _funds = GET_WARLORD_FUNDS(_warlordData);
				if (_funds > 0) then {
					// Create persistent warlord data
					private _persistentWarlordData = [time, GET_WARLORD_SIDE(_warlordData), _funds];
					// Save it to hashmap
					OWL_persistentWarlordsData set [_uid, _persistentWarlordData];
				};
			};
			
			// To delete an element from warlords data array we creating a shallow copy of it and modifying the copy,
			// instead of modifying the original array. This way if there's forEach loop iterating through original array during deletion
			// we won't shift elements in it, potentially causing forEach loop to skip an element.
			// See https://community.bistudio.com/wiki/forEach#Notes for more details
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


OWL_fnc_ownerIsValidWarlordPlayer = {
	// Params: ownerID
	
	!isNil { OWL_ownerToDataIndexMap get _this };
};


OWL_fnc_kickPlayer = {
	params ["_uid", "_name", "_reason"];
	
	private _succeeded = false;
	if (_name == "") then { _name = _uid; };
	[format ["Kicking out %1 (%2)", _name, _reason]] call OWL_fnc_log;
	if (isMultiplayer) then {
		_succeeded = serverCommand format ["#kick ""%1""", _uid];
		if (!_succeeded) then {
			[format ["Failed to kick %1", _name, _reason]] call OWL_fnc_log;
		};
	};
	_succeeded
};
