-module (web_add_job).
-include_lib ("nitrogen/include/wf.inc").
-compile(export_all).

%% Todo:
%% - Fix so the uploaded file is used in the cluster
%% - Fix validation of the form
%% - A redirect to a new page when job is started
%% - Fix ProblemType and ProgramType input

main() -> 
	#template { file="./wwwroot/template.html"}.

title() -> "LoPEC".

footer() -> "LoPEC 2009".

get_info() ->
    "Low Power Erlang-based Cluster".

menu() ->
    Event = #event { target=submenu, type=click },
    Menu = [
        #panel{id=menuitem, body=[
            #link{text="Dashboard", actions=Event#event {actions=#appear{}}}
            ]
        }
            
        ,
        #panel{id=menuitem, body=[
            #link{text="Node information", actions=Event#event {actions=#hide{}}}
            ]
        }
    ].

% Creates the submenu.        
submenu() ->
    Submenu = [
        #panel{id=menuitem, body=[
            #link{text="Current jobs"}
            ]
        },
        #panel{id=menuitem, body=[
            #link{text="Add new job", url="web_add_job"}
            ]
        },
        #panel{id=menuitem, body=[
            #link{text="User statistics"}
            ]
        },
        #panel{id=menuitem, body=[
            #link{text="Profile"}
            ]
        }
    ].

body() -> 
    {ok, Path} = configparser:read_config("/etc/clusterbusters.conf", cluster_root),
    ProgramFiles = lists:filter(
        fun(X) -> filelib:is_dir(X) end, filelib:wildcard(Path ++ "/programs/*")),
    ProgramTypes = lists:map(fun(T) -> #option {text=T,value=T} end, ProgramFiles),
    Body = [
    #h2{text="Add job"},
    #p{},
    #label { id=programType, text="Program type:" },
    #dropdown { options=
        ProgramTypes
    },
    #p{},
    #label { text="Problem type:"},
    #dropdown { id=problemType, options=[
        #option { text="mapreduce" }
    ]},
    #p{},
    #label { text="Username:"},
    #textbox { id=userTextBox, next=priorityTextBox },
    #p{},
    #label { text="Priority:"},
    #textbox { id=priorityTextBox, next=continueButton },
    #p{},
    #label { text="Programfile:" },
    #upload { tag=programupload, show_button=false },
    #p{},  
    #button { id=continueButton, text="Next", postback=continue }
    ],
    wf:wire(continueButton, userTextBox, #validate { validators=[
        #is_required { text="Required." }
    ]}),
    wf:wire(continueButton, priorityTextBox, #validate { validators=[
        #is_required { text="Required." },
        #is_integer { text="Must be an integer."}
    ]}),
    wf:render(Body)
    .

	

event(continue) ->
    [User] = wf:q(userTextBox),
    [Priority] = wf:q(priorityTextBox),
    %[ProblemType] = wf:q(problemType),
    %[ProgramType] = wf:q(programType),
    ProblemType = "mapreduce",
    ProgramType = "raytracer2",
    case listener:add_job(list_to_atom(ProgramType), list_to_atom(ProblemType), 
        list_to_atom(User), list_to_integer(Priority), "/storage/test/lol.txt") of
        {ok, JobId} -> wf:flash(wf:f("Added a new job with id: ~w", [JobId]));
        {error, Reason} -> wf:flash(wf:f("Could not add job. Reason: ~w", [Reason]))
    end,
    ok;

event(_) -> ok.


upload_event(_Tag, undefined, _) ->
  wf:flash("Please select a file."),
  ok;

upload_event(_Tag, FileName, LocalFileData) ->
    FileSize = filelib:file_size(LocalFileData),
    case filename:extension(FileName) of
        _ -> wf:flash(wf:f("Uploaded file: ~s (~p bytes)", [FileName, FileSize]))
    end,
    {ok, LocalFileData}.