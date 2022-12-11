#include "defines.hpp"

if (hasInterface or {isServer}) then {
	call compileFinal preprocessFileLineNumbers "Common\initCommon.sqf";
};
if (isServer) then {
	call compileFinal preprocessFileLineNumbers "Server\initServer.sqf";
};
if (hasInterface) then {
	call compileFinal preprocessFileLineNumbers "Client\initClient.sqf";
};

// :D
[] spawn compileFinal preprocessFileLineNumbers "TEMP.sqf";
