#include "..\defines.hpp"

waitUntil { not isNull player };
waitUntil { missionNamespace getVariable ["OWL_ServerInitialized", false] };
