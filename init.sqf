#include "defines.hpp"

if (hasInterface or {isServer}) then {
	call compileFinal preprocessFileLineNumbers "Common\InitCommon.sqf";
};
if (isServer) then {
	call compileFinal preprocessFileLineNumbers "Server\InitServer.sqf";
};
if (hasInterface) then {
	call compileFinal preprocessFileLineNumbers "Client\InitClient.sqf";
};

// :D
[] spawn compileFinal preprocessFileLineNumbers "TEMP.sqf";
