/************************************************************************************************************
Function: MSOT_fnc_startSignal

Description: Creates a GPS Signal Marker on a defined Vehicle.

             Client only

Parameters: [OBJECTNAME,SIZE,COLOR,ENDPOSITION,DISTANCE TO ENDPOSITION]

            OBJECTNAME     -    Name of the Vehicle that you want to observe
            SIZE           -    Size of the marker (GPS SIGNAL Diameter)
            COLOR          -    "GREY","BROWN","RED","ORANGE","YELLOW","GREEN","BLUE"
                                "PINK","WHITE"

            ENDPOSITION    -    Position that Ends the GPS Signal
            DISTANCE       -    Distance to Endposition where the GPS Signal ends


Returns: Nothing

Examples:
           nul = [DEALERCAR, 200, "RED", (getMarkerPos "HOMETOWN"), 100] call MSOT_fnc_startSignal;

Author: Fry
        Note:(inspired by nomisum - Gruppe Adler @ www.gruppe-adler.de)
*************************************************************************************************************/

MSOT_fnc_startSignal = {
If(isMultiplayer)then{If(hasInterface)exitWith{};};
_this remoteExec ["MSOT_fnc_signal",([0,-2] select isDedicated), true];
};

MSOT_fnc_creamarker = {
If(!hasInterface)exitWith{};
private ["_marker_name","_marker_color"];
params ["_pos","_color"];
_marker_name = "";
_marker_color = switch(toUpper _color)do
                {
                  case "GREY":{"ColorGrey"};
                  case "BROWN":{"ColorBrown"};
                  case "RED":{"ColorRed"};
                  case "ORANGE":{"ColorOrange"};
                  case "YELLOW":{"ColorYellow"};
                  case "GREEN":{"ColorGreen"};
                  case "BLUE":{"ColorBlue"};
                  case "PINK":{"ColorPink"};
                  case "WHITE":{"ColorWhite"};
                  default {"ColorRed"};
                };
If(isMultiplayer)then{
_marker_name = createMarkerLocal ["GPS_MARKER",[(_pos select 0),(_pos select 1)]];
_marker_name setMarkerShapeLocal "ELLIPSE";
_marker_name setMarkerTypeLocal "Empty";
_marker_name setMarkerColorLocal _marker_color;
_marker_name setMarkerBrushLocal "SolidBorder";
_marker_name setMarkerSizeLocal [1,1];
_marker_name setMarkerAlphaLocal 1;
}else{
  _marker_name = createMarker ["GPS_MARKER",[(_pos select 0),(_pos select 1)]];
  _marker_name setMarkerShape "ELLIPSE";
  _marker_name setMarkerType "Empty";
  _marker_name setMarkerColor _marker_color;
  _marker_name setMarkerBrush "SolidBorder";
  _marker_name setMarkerSize [1,1];
  _marker_name setMarkerAlpha 1;
};
_marker_name
};

MSOT_fnc_setSize = {
If(!hasInterface)exitWith{};
private ["_amp","_timer_counter","_alpha_counter","_ctrl_size","_ctrl_alpha","_ctrl_alpha2"];
params ["_marker_name","_sized","_frequency"];
_amp = _sized * _frequency;
_timer_counter = 1 / _amp;
_alpha_counter = 10 / _sized;
_ctrl_size = 0;
_ctrl_alpha = 1;
_ctrl_alpha2 = 10;

while{missionNamespace getVariable ["msot_gps_signal",true]}do
{
 if(_ctrl_size >= _sized)then{_ctrl_size = 0;};
 if(_ctrl_alpha < 0.1)then{_ctrl_alpha2 = 10;};
 while{_ctrl_size < _sized}do
 {
   _ctrl_size = _ctrl_size + 1; _ctrl_alpha2 = _ctrl_alpha2 - _alpha_counter;
   _ctrl_alpha = ((round _ctrl_alpha2) * 0.1);
   //hintSilent format["%1\n%2",_ctrl_size,_ctrl_alpha];
   If(isMultiplayer)then{
   _marker_name setMarkerSizeLocal [_ctrl_size,_ctrl_size];
   _marker_name setMarkerAlphaLocal _ctrl_alpha;
 }else{
   _marker_name setMarkerSize [_ctrl_size,_ctrl_size];
   _marker_name setMarkerAlpha _ctrl_alpha;
 };
 sleep _timer_counter;
 };
};
};

MSOT_fnc_signal = {
If(!hasInterface)exitWith{};
private ["_interval_follow","_interval_frequency","_pos_obj","_marker"];
params ["_object","_size","_color","_finish_pos","_dist_finish"];

_interval_follow = 2;       //Delay for set Marker to Object
_interval_frequency = 1;  // Frequency 0.1 - 1 possible

If(_interval_frequency >= 0.1 && {_interval_frequency <= 1})then{
_pos_obj = position _object;
missionNamespace setVariable ["msot_gps_signal",true,false];
waitUntil{(speed _object) > 3 || {(damage _object) > 0.6} || {(_object distance _finish_pos) < _dist_finish}};
hint "läuft an";
If(damage _object < 0.6 && {(_object distance _finish_pos) > _dist_finish})then
{
  _marker = [_pos_obj,_color] call MSOT_fnc_creamarker;
  [_marker,_size,_interval_frequency] spawn MSOT_fnc_setSize;
  while{(damage _object) <= 0.6 && {(_object distance _finish_pos) > _dist_finish} && {!((driver _object) isEqualTo objNull)}}do
  {
   _pos_obj = position _object;
   If(isMultiplayer)then{
   _marker setMarkerPosLocal [(_pos_obj select 0),(_pos_obj select 1)];
   }else{_marker setMarkerPos [(_pos_obj select 0),(_pos_obj select 1)];};
   sleep _interval_follow;
  };
  missionNamespace setVariable ["msot_gps_signal",false,false];
  If(isMultiplayer)then{deleteMarkerLocal _marker;}else{deleteMarker _marker;};
};
}else{hint "Interval Frequency is not in the permitted range!"};
};
