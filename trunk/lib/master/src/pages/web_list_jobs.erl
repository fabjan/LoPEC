-module (web_list_jobs).
-include_lib ("nitrogen/include/wf.inc").
-compile(export_all).


%% TODO:
%% - Fix a comet-process so the jobTable is updated in intervals
%% - A nice rounded panel
%% - Some nicer table perhaps?
%% - Pause/Resume buttons
%% - Hyperlink on the JobId so the user could see more information
main() -> 
	#template { file="./wwwroot/template.html"}.

title() ->
	"LoPEC".

subtitle() ->
    "".

footer() ->
    "LoPEC 2009".

submenu() ->
    [].


get_jobs([]) ->
    [];
get_jobs([H|T]) ->
    IdString = lists:flatten(io_lib:format("~p", [H])),
    [
        #tablerow { cells=[
            #tablecell { body=[#link { body = [#image{ image = "/images/delete.gif" }], postback={delete, H}}]},
            #tablecell { text=IdString }
        ]} 
    |[get_jobs(T)]].

get_job_table() ->
    #table { id=jobTable, 
        rows = [
            #tablerow { cells=[
                #tableheader { text="Delete     " },
                #tableheader { text="JobId" }
            ]}|get_jobs(db:list_active_jobs())
        ]
    }.

body() ->
    case wf:get_path_info() of 
        "" -> 
            Body = [
                get_job_table()
            ];
        JobString -> 
            JobId = list_to_integer(JobString),
            Stats = statistician:get_job_stats(JobId, string),
            case Stats of 
                {error, Reason} -> Body = [#label { text=Reason }];
                _ -> Body = [#label{text=Stats}]
            end
    end,
 
    wf:render(Body).

event({delete, JobId}) ->
    wf:wire(#confirm { text = "Are you sure?", postback={confirm_delete, JobId}});
event({confirm_delete, JobId}) ->
    listener:cancel_job(JobId),
    wf:flash(wf:f("Removed job with Id: ~w", [JobId])),
    wf:update(jobTable, get_job_table());
event(_) -> ok.
