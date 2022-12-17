
//call compileFinal preprocessFileLineNumbers "TEMP.sqf";

if (hasInterface || {isServer}) then {
	call compileFinal preprocessFileLineNumbers "Common\initCommon.sqf";
};
if (isServer) then {
	call compileFinal preprocessFileLineNumbers "Server\initServer.sqf";
};
if (hasInterface) then {
	call compileFinal preprocessFileLineNumbers "Client\initClient.sqf";
};
