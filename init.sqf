
OWL_devMode = true;

[] spawn compileFinal preprocessFileLineNumbers "TEMP.sqf";

startLoadingScreen ["Open Warlords loading..."];

if (hasInterface || {isServer}) then {
	call compileFinal preprocessFileLineNumbers "Common\initCommon.sqf";
};
if (isServer) then {
	call compileFinal preprocessFileLineNumbers "Server\initServer.sqf";
};
if (hasInterface) then {
	call compileFinal preprocessFileLineNumbers "Client\initClient.sqf";
};
endLoadingScreen;