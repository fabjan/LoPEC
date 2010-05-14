-module (web_info).
-include_lib ("nitrogen/include/wf.inc").
-compile(export_all).

main() ->
    common_web:main().

title() ->
    common_web:title().

footer() ->
    common_web:footer().

get_info() ->
    common_web:get_info().

% Creates the menu.
menu() ->
    common_web:menu().

% Creates the submenu.        
submenu() ->
    common_web:submenu().

body() ->
    #rounded_panel { color=gray, body=[
	    #label{text="Dansa!"},
      "This is a rounded panel."
    ]}.
	
event(_) -> ok.
