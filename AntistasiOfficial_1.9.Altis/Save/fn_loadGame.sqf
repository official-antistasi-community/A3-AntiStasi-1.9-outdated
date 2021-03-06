if (!isServer) exitWith {};
statsLoaded = 0; publicVariable "statsLoaded";
petros allowdamage false;

//ADD STATS THAT NEED TO BE LOADED HERE.

//preinit
["posHQ"] call fn_loadData; publicVariable "posHQ";
["campaign_playerList"] call fn_loadData;
["membersPool"] call fn_loadData; publicVariable "membersPool";
flag_playerList = true;
publicVariable "flag_playerList";

//game
["enableMemAcc"] call fn_loadData;
["enableOldFT"] call fn_loadData;
["campList"] call fn_loadData; publicVariable "campList"; publicVariable "campsFIA";
["emplacements"] call fn_loadData; publicVariable "outpostsFIA"; publicVariable "FIA_RB_list"; publicVariable "FIA_WP_list";
["mrkFIA"] call fn_loadData; mrkFIA = mrkFIA + outpostsFIA; publicVariable "mrkFIA"; if (isMultiplayer) then {sleep 5};
["mrkAAF"] call fn_loadData;
["supplySaveArray"] call fn_loadData;
if(isnil "supplySaveArray") then {supplySaveArray = [];}; publicVariable "supplySaveArray";
["destroyedCities"] call fn_loadData; publicVariable "destroyedCities";
["mines"] call fn_loadData;
["countCA"] call fn_loadData; publicVariable "countCA";
["antennas"] call fn_loadData; publicVariable "antennas";
["prestigeNATO"] call fn_loadData;
["prestigeCSAT"] call fn_loadData;
["hr"] call fn_loadData;
["planesAAFcurrent"] call fn_loadData; publicVariable "planesAAFcurrent";
["helisAAFcurrent"] call fn_loadData; publicVariable "helisAAFcurrent";
["APCAAFcurrent"] call fn_loadData; publicVariable "APCAAFcurrent";
["tanksAAFcurrent"] call fn_loadData; publicVariable "tanksAAFcurrent";
["weapons"] call fn_loadData;
["magazines"] call fn_loadData;
["items"] call fn_loadData;
["backpacks"] call fn_loadData;
["time"] call fn_loadData;
["supportOPFOR"] call fn_loadData;
["supportBLUFOR"] call fn_loadData;
["supplyLevels"] call fn_loadData;
["resourcesAAF"] call fn_loadData;
["resourcesFIA"] call fn_loadData;
["garrison"] call fn_loadData;
["skillFIA"] call fn_loadData;
["skillAAF"] call fn_loadData; publicVariable "skillAAF";
["distanceSPWN"] call fn_loadData; publicVariable "distanceSPWN";
["civPerc"] call fn_loadData; publicVariable "civPerc";
["minimoFPS"] call fn_loadData; publicVariable "minimoFPS";
["smallCAmrk"] call fn_loadData;
["vehInGarage"] call fn_loadData; publicVariable "vehInGarage";
["destroyedBuildings"] call fn_loadData;
["idleBases"] call fn_loadData;
["AS_destroyedZones"] call fn_loadData; publicVariable "AS_destroyedZones";

["unlockedItems"] call fn_loadData; publicVariable "unlockedOptics";
["unlockedMagazines"] call fn_loadData; publicVariable "unlockedMagazines";
["unlockedWeapons"] call fn_loadData; publicVariable "unlockedWeapons";
["unlockedBackpacks"] call fn_loadData; publicVariable "unlockedBackpacks";
unlockedRifles = unlockedweapons - gear_sidearms - gear_missileLaunchers - gear_rocketLaunchers - gear_sniperRifles - gear_machineGuns; publicVariable "unlockedRifles";

["jna_dataList"] call fn_loadData;
["jng_vehicleList"] call fn_loadData;

//Sparker's War Statistics data
//["ws_grid"] call fn_loadData;
//===========================================================================

{
	[(_x select 0), (_x select 1)] remoteExec ["createSupplyBox", call AS_fnc_getNextWorker];
} forEach supplySaveArray;

_markers = mrkFIA + mrkAAF + campsFIA;

{
	_position = getMarkerPos _x;
	_nearestZone = [_markers,_position] call BIS_fnc_nearestPosition;
	if (_nearestZone in mrkFIA) then {
		mrkAAF = mrkAAF - [_x];
		mrkFIA = mrkFIA + [_x];
	} else {
		mrkAAF = mrkAAF + [_x];
	};
} forEach controlsX;

{
	if (!(_x in mrkAAF) AND !(_x in mrkFIA) AND (_x != "FIA_HQ")) then {mrkAAF pushBackUnique _x};
} forEach markers;

_markers = _markers + controlsX;
{

	if (_x in mrkFIA) then {
		private ["_mrkD"];
		call {
			if (_x != "FIA_HQ") then {
				_mrkD = format ["Dum%1",_x];
				_mrkD setMarkerColor guer_marker_colour;
			};

			if (_x in airportsX) exitWith {
				_mrkD setMarkerText format [localize "STR_GL_MAP_AP1",count (garrison getVariable _x), A3_Str_BLUE];
				_mrkD setMarkerType guer_marker_type;
				planesAAFmax = planesAAFmax - 1;
			    helisAAFmax = helisAAFmax - 2;
			};

			if (_x in bases) exitWith {
				_mrkD setMarkerText format [localize "STR_GL_MAP_MB1",count (garrison getVariable _x), A3_Str_BLUE];
				_mrkD setMarkerType guer_marker_type;
				APCAAFmax = APCAAFmax - 2;
		    	tanksAAFmax = tanksAAFmax - 1;
			};

			if (_x in outposts) exitWith {
				_mrkD setMarkerText format [localize "STR_GL_MAP_OP1",count (garrison getVariable _x), A3_Str_PLAYER];
			};

			if (_x in citiesX) exitWith {
				_power = [power, getMarkerPos _x] call BIS_fnc_nearestPosition;
				if (!(_power in mrkFIA) OR (_power in destroyedCities)) then {
					[_x,false] spawn AS_fnc_adjustLamps;
				};
				if (_x in destroyedCities) then {[_x] call AS_fnc_destroyCity};
			};

			if ((_x in resourcesX) OR (_x in factories)) exitWith {
				if (_x in resourcesX) then {_mrkD setMarkerText format [localize "STR_GL_MAP_RS"+": %1",count (garrison getVariable _x)]} else {_mrkD setMarkerText format [localize "STR_GL_MAP_FAC"+": %1",count (garrison getVariable _x)]};
				_power = [power, getMarkerPos _x] call BIS_fnc_nearestPosition;
				if (!(_power in mrkFIA) OR (_power in destroyedCities)) then {
					[_x,false] spawn AS_fnc_adjustLamps;
				};
				if (_x in destroyedCities) then {[_x] call AS_fnc_destroyCity};
			};

			if (_x in seaports) exitWith {
				_mrkD setMarkerText format [localize "STR_GL_MAP_SP"+": %1",count (garrison getVariable _x)];
			};

			if (_x in power) exitWith {
				_mrkD setMarkerText format [localize "STR_GL_MAP_PP"+": %1",count (garrison getVariable _x)];
				if (_x in destroyedCities) then {[_x] call AS_fnc_destroyCity};
			};
		};
	};

	if (_x in mrkAAF) then {
		call {
			if (_x in citiesX) exitWith {
				_power = [power, getMarkerPos _x] call BIS_fnc_nearestPosition;
				if (!(_power in mrkAAF) OR (_power in destroyedCities)) then {
					[_x,false] spawn AS_fnc_adjustLamps;
				};
				if (_x in destroyedCities) then {[_x] call AS_fnc_destroyCity};
			};

			if ((_x in resourcesX) OR (_x in factories)) exitWith {
				_power = [power, getMarkerPos _x] call BIS_fnc_nearestPosition;
				if (!(_power in mrkAAF) OR (_power in destroyedCities)) then {
					[_x,false] spawn AS_fnc_adjustLamps;
				};
				if (_x in destroyedCities) then {[_x] call AS_fnc_destroyCity};
			};

			if ((_x in power) AND (_x in destroyedCities)) exitWith {[_x] call AS_fnc_destroyCity};
		};
	};
} forEach _markers;

{
	if !(_x in _markers) then {
		if (_x != "FIA_HQ") then {
			_markers pushBack _x;
			mrkAAF pushback _x;
		} else {
			mrkAAF = mrkAAF - ["FIA_HQ"];
			if !("FIA_HQ" in mrkFIA) then {
				mrkFIA = mrkFIA + ["FIA_HQ"];
			};
		};
	};
} forEach markers;

markers = _markers;
publicVariable "markers";
publicVariable "mrkAAF";
publicVariable "mrkFIA";


["flag_chopForest"] call fn_loadData; publicVariable "flag_chopForest";
["objectsHQ"] call fn_loadData;
["addObjectsHQ"] call fn_loadData;
["vehicles"] call fn_loadData; publicVariable "staticsToSave";

sleep 2;

if !(activeJNA) then {
	[] call AS_fnc_updateArsenal;
};

server setVariable ["genLMGlocked",true,true];
server setVariable ["genGLlocked",true,true];
server setVariable ["genSNPRlocked",true,true];
server setVariable ["genATlocked",true,true];
server setVariable ["genAAlocked",true,true];
[unlockedWeapons] spawn AS_fnc_weaponsCheck;

["BE_data"] call fn_loadData;

ASA3_saveLoaded = true;
placementDone = true; publicVariable 'placementDone';
diag_log "Antistasi: Server sided Persistent Load done";

sleep 25;
["tasks"] call fn_loadData;

_tmpCAmrk = + smallCAmrk;
smallCAmrk = [];

{
	_base = [_x] call AS_fnc_findBaseForCA;
	_radio = [_x] call AS_fnc_radioCheck;
	if ((_base != "") AND (_radio) AND (_x in mrkFIA) AND !(_x in smallCAmrk)) then {
		[_x] remoteExec ["patrolCA", call AS_fnc_getNextWorker];
		sleep 5;
		smallCAmrk pushBackUnique _x;
		[_x] remoteExec ["autoGarrison", call AS_fnc_getNextWorker];
	};
} forEach _tmpCAmrk;
publicVariable "smallCAmrk";

petros allowdamage true;
