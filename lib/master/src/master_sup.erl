%%%-------------------------------------------------------------------
%%% @author Vasilij Savin <vasilij.savin@gmail.com>
%%% @author Gustav Simonsson <gusi7871@student.uu.se>
%%% @doc
%%% Master supervisor supervises WPM processes.
%%% Currently there are 3 processes to monitor:
%%% Listener   - listen to job submissions from users
%%% DbDaemon   - interaction with DB
%%% Dispatcher - listens to task requests from nodes  
%%% @end
%%% Created : Oct 2, 2009 by Vasilij Savin <vasilij.savin@gmail.com> 
%%% -------------------------------------------------------------------
-module(master_sup).
-behaviour(supervisor).

-ifdef(debug).
-define(DB_START_VAL(), [test]).
-else.
-define(DB_START_VAL(), no_args).
-endif.

-export([start_link/0]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([init/1]).

%% ====================================================================
%% Server functions
%% ====================================================================

start_link() ->
    chronicler:info("~w : module started~n", [?MODULE]),
    supervisor:start_link({local, ?MODULE}, ?MODULE, no_args).

%% --------------------------------------------------------------------
%% Func: init/1
%% All arguments are ignored.
%% Returns: {ok,  {SupervisorConfig,  [ChildSpec]}} |
%%          ignore                                  |
%%          {error, Reason}
%% --------------------------------------------------------------------
init(no_args) ->
    % Children specification:
    % Process name
    % {Module, Func, Args} - Start function
    % RestartType
    % ShutdownTime
    % Type: worker | supervisor
    % Used modules
    chronicler:info("~w : creating children~n", [?MODULE]),
    Dispatcher = child(dispatcher, worker, no_args),
    Listener = child(listener, worker, no_args),
    DbDaemon = child(db, worker, ?DB_START_VAL()),
    Statistician = child(statistician, worker, [master]),
    Examiner = child(examiner, worker, no_args),
    % @todo make the io module configurable instead of hard coded
    IoModule =
        child(io_module, worker,
              case application:get_env(storage_backend) of
                  {ok, fs} -> [fs_io_module, no_args];
                  {ok, riak} ->
                      {ok, Interface} = application:get_env(riak_interface),
                      {ok, [{addr, {A,B,C,D}}]} = inet:ifget(Interface, [addr]),
                      IP = lists:concat([A,".",B,".",C,".",D]),
                      [riak_io_module,
                       [{riak_node, list_to_atom("riak@" ++ IP)}]]
              end),
    % Returning supervisor specification
    {ok,{{one_for_one,1,60},
         [Dispatcher, DbDaemon, IoModule, Listener, Examiner, Statistician]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
%%--------------------------------------------------------------------
%% @private
%% @doc
%% Simple helper function to make the child specification list easier
%% to read.
%%
%% @spec child(Module, Role, Args) -> {ChildSpec}
%% @end
%%--------------------------------------------------------------------
child(Module,Role, no_args) ->
    {Module, {Module, start_link, []},
        permanent, brutal_kill, Role, [Module]};
child(Module,Role, Args) ->
    {Module, {Module, start_link, Args},
        permanent, brutal_kill, Role, [Module]}.
