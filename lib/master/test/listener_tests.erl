%%%-------------------------------------------------------------------
%%% @author Burbas, Vasilij Savin <>
%%% @doc
%%%
%%% Contains the unit tests for the job listener. 
%%%
%%% @end
%%% Created : 14 Oct 2009 by Vasilij <>
%%%-------------------------------------------------------------------
-module(listener_tests).
-include("../include/db.hrl").
-include_lib("eunit/include/eunit.hrl").

listener_test_() ->
    {setup,
     fun tests_init/0,
     fun tests_stop/1,
     fun ({JobId, JobId2}) ->
             {inorder,
              [
               ?_assertMatch({error, enoent},
                   listener:add_job(wordcount, mapreduce, kalle, 5, "If%you&have-this*file+you!are.a'silly)banana")),
               ?_assertMatch({error, _Reason}, listener:pause_job(123123)),
               ?_assertEqual(anonymous, listener:get_job_name(JobId)),
               ?_assertEqual({name, "ApanJansson"},
                              listener:get_job_name(JobId2)),
               ?_assertEqual(ok, listener:pause_job(JobId)),

               % This is a non-existing job
               ?_assertEqual(anonymous, listener:get_job_name(123)),
               ?_assertEqual(ok, listener:resume_job(JobId))
              ]
             }
     end
    }.

tests_init() ->
    ok = application:start(common),
    ok = application:start(chronicler),
    ok = application:start(mainChronicler),
    ok = application:start(ecg),
    ok = application:start(master),
    chronicler:set_logging_level([all]),

    %db:create_tables(ram_copies),
    %examiner:start_link(),
    %listener:start_link(),
    %dispatcher:start_link(),
    {ok, Root} = application:get_env(cluster_root),
    {ok, JobId} = listener:add_job(raytracer, mapreduce, owner, 0,
                                            Root++"lol.txt"),
    {ok, JobId2} = listener:add_job(raytracer, mapreduce, owner2, 1,
                                    Root++"lol.txt", "ApanJansson"),
    {JobId, JobId2}.

tests_stop(_) ->
    ok = application:stop(master),
    ok = application:stop(ecg),
    ok = application:stop(mainChronicler),
    ok = application:stop(chronicler),
    ok = application:stop(common),
    %examiner:stop(),
    db:stop(),
    timer:sleep(10). %fuck you erlang we shouldnt have to wait for db to stop 
