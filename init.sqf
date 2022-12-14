#include "defines.hpp"

// Try to avoid using init.sqf when it's not really necessary

call compileFinal preprocessFileLineNumbers "TEMP.sqf";

if (hasInterface or {isServer}) then {
	call compileFinal preprocessFileLineNumbers "Common\initCommon.sqf";
};
if (isServer) then {
	call compileFinal preprocessFileLineNumbers "Server\initServer.sqf";
};
if (hasInterface) then {
	call compileFinal preprocessFileLineNumbers "Client\initClient.sqf";
};
