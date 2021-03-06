/*====================================================MCC_fnc_MWObjectiveDestroy====================================================================================
// Create a Destroy objective
// Example:[_objPos,_isCQB,_side,_faction] call MCC_fnc_MWObjectiveDestroy;
// _objPos = position, objectice position
//_isCQB = Boolean, true - for CQB areay false if it doesn't matters.
//_side = enemy side
//_faction = enemy Faction
// Return - nothing
//===========================================================================================================================================================*/
private ["_objPos","_isCQB","_side","_faction","_preciseMarkers","_type","_objType","_typeSize","_spawnPos","_object","_dummyObject","_spawndir","_unitsArray","_group","_init","_range","_campaignMission","_sidePlayer"];

_objPos 		= _this select 0;
_isCQB 			= _this select 1;
_side 			= _this select 2;
_faction 		= _this select 3;
_preciseMarkers = _this select 4;
_campaignMission = [_this, 6, false, [false]] call BIS_fnc_param;
_sidePlayer = [_this, 7, west] call BIS_fnc_param;

_objType = switch (_this select 5) do
			{
				case "Destroy Vehicle": {["tanks","air"] call BIS_fnc_selectRandom};
				case "Destroy AA": {"aa"};
				case "Destroy Artillery": {"artillery"};
				case "Destroy Weapon Cahce": {"cache"};
				case "Destroy Fuel Depot": {"fuel"};
				case "Destroy Radar/Radio": {if (_campaignMission) then {"radio"} else {["radar","radio"] call BIS_fnc_selectRandom}};
			};


//What do we spawn
switch _objType do
{
	case "fuel":
	{
		_type =  (missionNamespace getVariable ["MCC_MWFuelTanks",["Land_dp_smallTank_F","Land_ReservoirTank_V1_F","Land_dp_bigTank_F"]]) call BIS_fnc_selectRandom;
	};

	case "radio":
	{
		_type =  (missionNamespace getVariable ["MCC_MWRadio",["Land_TTowerBig_2_F"]]) call BIS_fnc_selectRandom;
	};

	case "tanks":
	{
		_type =  (missionNamespace getVariable ["MCC_MWTanks",["B_MBT_01_cannon_F","O_MBT_02_cannon_F"]]) call BIS_fnc_selectRandom;
	};

	case "aa":
	{
		_type = switch _side do
				{
					case west:
					{
						(missionNamespace getVariable ["MCC_MWAAB",["B_APC_Tracked_01_AA_F"]]) call BIS_fnc_selectRandom;
					};

					case east:
					{
						(missionNamespace getVariable ["MCC_MWAAO",["O_APC_Tracked_02_AA_F"]]) call BIS_fnc_selectRandom;
					};

					case resistance:
					{
						(missionNamespace getVariable ["MCC_MWAAI",["I_APC_Wheeled_03_cannon_F"]]) call BIS_fnc_selectRandom;
					};

					case default
					{
						(missionNamespace getVariable ["MCC_MWAAO",["O_APC_Tracked_02_AA_F"]]) call BIS_fnc_selectRandom;
					};
				};
	};

	case "artillery":
	{
		_type = switch _side do
				{
					case west:
					{
						(missionNamespace getVariable ["MCC_MWArtilleryB",["B_MBT_01_arty_F","B_MBT_01_mlrs_F"]]) call BIS_fnc_selectRandom;
					};

					case east:
					{
						(missionNamespace getVariable ["MCC_MWArtilleryO",["O_MBT_02_arty_F","O_Mortar_01_F"]]) call BIS_fnc_selectRandom;
					};

					case resistance:
					{
						(missionNamespace getVariable ["MCC_MWArtilleryI",["I_Mortar_01_F"]]) call BIS_fnc_selectRandom;
					};

					case default
					{
						(missionNamespace getVariable ["MCC_MWArtilleryO",["B_APC_Tracked_01_AA_F"]]) call BIS_fnc_selectRandom;
					};
				};
	};

	case "air":
	{
		_type =  (missionNamespace getVariable ["MCC_MWAir",["O_Heli_Attack_02_F","O_Heli_Attack_02_black_F","O_UAV_02_F","O_UAV_02_CAS_F","B_Heli_Attack_01_F","I_Plane_Fighter_03_CAS_F","I_Plane_Fighter_03_AA_F"]]) call BIS_fnc_selectRandom;
	};

	case "cache":
	{
		_type =  (missionNamespace getVariable ["MCC_MWcache",["Box_East_AmmoVeh_F"]]) call BIS_fnc_selectRandom;
	};

	case "radar":
	{
		_type =  (missionNamespace getVariable ["MCC_MWradar",["Land_Radar_Small_F"]]) call BIS_fnc_selectRandom;
	};

	default
	{
		_type =  (missionNamespace getVariable ["MCC_MWFuelTanks",["Land_dp_smallTank_F","Land_ReservoirTank_V1_F","Land_dp_bigTank_F"]]) call BIS_fnc_selectRandom;
	};
};

//How big is it
_typeSize = switch _objType do
				{
					case "tanks":
					{
						"Land_dp_bigTank_F"
					};

					case "aa":
					{
						"Land_dp_bigTank_F"
					};

					case "artillery":
					{
						"Land_dp_bigTank_F"
					};

					case "air":
					{
						"Land_TentHangar_V1_F"
					};

					case "cache":
					{
						"Land_dp_smallTank_F"
					};

					default
					{
						_type
					};
				};

//Find an empry spot
_range = 50;
_spawnPos = [_objPos,1,_range,10,0,10,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;

//If we haven't find it in first time increase by 50;
while {str _spawnPos == "[-500,-500,0]"} do
{
	_range = _range+ 50;
	_spawnPos = [_objPos,1,_range,10,0,10,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;
	//_spawnPos = _objPos findEmptyPosition [0,200,_typeSize];
};


//Case we are dealing with a vehicle
if (_objType in ["tanks","aa","artillery"]) then
{
	_dummyObject =[_spawnPos, random 360, "c_nestBig"] call MCC_fnc_objectMapper;
	_spawnPos = getpos _dummyObject;
	_spawndir = getdir _dummyObject;
};

//Case we are dealing with ammo cache
if (_objType == "cache") then
{
	_dummyObject = [_spawnPos, random 360, "c_nestSmall"] call MCC_fnc_objectMapper;
	_spawnPos = getpos _dummyObject;
	_spawndir = getdir _dummyObject;
};

//Case we are dealing with a Air
if (_objType == "air") then
{
	_dummyObject =[_spawnPos, random 360, "c_hanger"] call MCC_fnc_objectMapper;
	_spawnPos = getpos _dummyObject;
	_spawndir = getdir _dummyObject;
};


 if (isnil "_spawndir") then {_spawndir = random 360};

sleep 1;

//Create the object
if (_objType in ["artillery","aa"]) then {
	_object = ([_spawnPos,_spawndir,_type,_side] call BIS_fnc_spawnVehicle) select 0;
} else {
	_object = _type createvehicle _spawnPos;
	_object setpos _spawnPos;
	_object setdir _spawndir;
};

//destroy only with satchel
if (_objType in ["tanks","aa","artillery","air"]) then {
		_init = '_this setVehicleLock "LOCKED";';
	_init = '_this setVehicleLock "LOCKED";';
	[[[netID _object,_object], _init, false], "MCC_fnc_setVehicleInit", false, false] spawn BIS_fnc_MP;

	if (_objType isEqualTo "artillery") then {[0,_object] spawn MCC_fnc_amb_Art};
	if (_objType isEqualTo "aa") then {[2,_object] spawn MCC_fnc_amb_Art};
};


//Add to curator
{_x addCuratorEditableObjects [[_object],true]} forEach allCurators;

//Start Briefings
switch _objType do
{
	case "tanks":
	{
		[_object,"destroy_tanks",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	case "aa":
	{
		[_object,"destroy_aa",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	case "artillery":
	{
		[_object,"destroy_artillery",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	case "air":
	{
		[_object,"destroy_tanks",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	case "cache":
	{
		[_object,"destroy_cache",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	case "fuel":
	{
		[_object,"destroy_fuel",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	case "radio":
	{
		[_object,"destroy_radio",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	case "radar":
	{
		[_object,"destroy_radar",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	default
	{
		[_object,"destroy_cache",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};
};