#include "..\defines.hpp"


// updateSectorSide
OWL_fnc_USS = {
	// I made this function mainly for testing the new sync system
	if (isMultiplayer && {remoteExecutedOwner != 2}) exitWith {};
	params ["_sectorID", "_newSide"];
	
	private _sector = OWL_allSectors # _sectorID;
	_sector setVariable ["OWL_syncd_sectorSide", _newSide];
	
	private _markerColor = _newSide call OWL_fnc_sideToMarkerColor;
	{
		_x setMarkerColorLocal _markerColor;
	} forEach (_sector getVariable "OWL_sectorMarkers");
	
	titleText [format ["%1 captured the %2", _newSide, _sector getVariable "OWL_sectorName"], "PLAIN DOWN"];
};


// warlordInitCallback
OWL_fnc_WIC = {
	if (isMultiplayer && {remoteExecutedOwner != 2}) exitWith {};
	if (OWL_serverInitializedMe) exitWith { ["OWL_fnc_warlordInitCallback got called twice?"] call OWL_fnc_log; };
	
	private _handshakeAccepted = _this#0;
	
	if (!_handshakeAccepted) exitWith {
		["Client initialization serverside failed. Quitting..."] call OWL_fnc_log;
		endMission "[OWL] Client initialization failed";
		forceEnd;
	};
	
	
	// HERE WE UNPACK THE DATA ARRAY WE RECEIVED
	//  ||
	//  ||
	//  \/
	
	isNil {
		private _jipData = _this#1;
		
		private _sectorsData = _jipData#0;
		
		{
			private _side = _sectorsData # _forEachIndex # 0;
			private _markerColor = _side call OWL_fnc_sideToMarkerColor;
			_x setVariable ["OWL_syncd_sectorSide", _side];
			
			{
				_x setMarkerColorLocal _markerColor;
			} forEach (_x getVariable "OWL_sectorMarkers");
		} forEach OWL_allSectors;
		
		OWL_myFunds = _jipData#3#0;
		[OWL_myFunds, OWL_myFunds] call OWL_fnc_temporaryFunc;
		
		OWL_serverInitializedMe = true;
		OWL_listenToREUpdates = true;
	};
};


OWL_fnc_temporaryFunc = {
	_this spawn {
		disableSerialization;
		private _display = findDisplay 46;
		if (isNull _display) exitWith {};
		private _ctrlFundsText = _display displayCtrl 1337;
		if (isNull _ctrlFundsText) then {
			_ctrlFundsText = _display ctrlCreate ["RscStructuredText", 1337];
			
			private _w = 1;
			private _h = 0.2;
			private _x = safezoneX + safezoneW * 0.9;
			private _y = safezoneY + safezoneH * 0.75;
			
			_ctrlFundsText ctrlSetPosition [_x, _y, _w, _h];
			_ctrlFundsText ctrlSetBackgroundColor [0, 0, 0, 0];
			_ctrlFundsText ctrlEnable true;
			_ctrlFundsText ctrlCommit 0;
		};
		
		_ctrlFundsText ctrlSetStructuredText parseText format ["<t size='2' shadow='2'>%1 CP</t>", _this # 0];
		playSound "addItemOk";
		
		private _pos = ctrlPosition _ctrlFundsText;
		private _w = 0.1;
		private _h = 0.05;
		private _x = _pos#0;
		private _y = _pos#1 - _h;
		
		private _ctrlFloatingText = _display ctrlCreate ["RscText", -1];
		_ctrlFloatingText ctrlSetText format ["+%1 CP", _this # 1];
		_ctrlFloatingText ctrlSetPosition [_x, _y, _w, _h];
		_ctrlFloatingText ctrlSetBackgroundColor [0, 0, 0, 0];
		_ctrlFloatingText ctrlCommit 0;
		waitUntil { ctrlCommitted _ctrlFloatingText };
		
		_ctrlFloatingText ctrlSetPosition [_x, _y - 0.1];
		_ctrlFloatingText ctrlSetFade 1;
		_ctrlFloatingText ctrlCommit 1;
		waitUntil { sleep 1; ctrlCommitted _ctrlFloatingText };
		
		ctrlDelete _ctrlFloatingText;
	};
};


OWL_fnc_sectorVoteTableUpdate = {
	if ( !(missionNamespace getVariable ["OWL_listenToREUpdates", false]) ) exitWith {};
	if (isMultiplayer && {remoteExecutedOwner != 2}) exitWith {};
	
	_voteTable = missionNamespace getVariable ["OWL_sectorVoteTable", []];
	_voteTable = _voteTable # (OWL_competingSides find (side player));
};


OWL_fnc_sectorVoteBegin = {
	if ( !(missionNamespace getVariable ["OWL_listenToREUpdates", false]) ) exitWith {};
	if (isMultiplayer && {remoteExecutedOwner != 2}) exitWith {};
	
	_votingEnds = OWL_sectorVoteStartTime # (OWL_competingSides find (side player));
	_currentSector = missionNamespace getVariable [format ["OWL_currentSector_%1", side player], objNull];
};


OWL_fnc_sectorSelected = {
	if ( !(missionNamespace getVariable ["OWL_listenToREUpdates", false]) ) exitWith {};
	if (isMultiplayer && {remoteExecutedOwner != 2}) exitWith {};
	
	params ["_side", "_newSector"];
	[format ["Client Update: New sector chosen for %1: %2", _side, _newSector getVariable "OWL_sectorName"]] call OWL_fnc_log;
	"BIS_WL_Selected_WEST" call OWL_fnc_eventAnnouncer;
	format ["SECTOR SELECTED: %1", toUpper (_newSector getVariable "OWL_sectorName")] spawn BIS_fnc_WLSmoothText;
	{_x setMarkerAlpha 0;} forEach (_newSector getVariable "OWL_sectorBorderMarkers");
};

OWL_inRestrictedArea = {
	params ["_timeStamp"];

	systemChat format ["Time Until Death: %1", _timeStamp - serverTime];
};
