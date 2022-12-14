#include "..\defines.hpp"

waitUntil { !isNull player };
waitUntil { missionNamespace getVariable ["OWL_ServerInitialized", false] };
