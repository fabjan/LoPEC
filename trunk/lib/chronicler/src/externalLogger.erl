%%%-------------------------------------------------------------------
%%% @private
%%% @author Fredrik Andersson <sedrik@consbox.se>
%%% @copyright (C) 2009, Clusterbusters
%%% @doc the terminalLogger is an event handler that will print the logging
%%% messages to a external logger.
%%% @end
%%% Created : 29 Sep 2009 by Fredrik Andersson <sedrik@consbox.se>
%%%-------------------------------------------------------------------
-module(externalLogger).
-behaviour(gen_event).

-include("../include/chroniclerState.hrl").

-define(EXTERNAL_LOGGER, main_chronicler).

-export([init/1,
        handle_event/2,
        terminate/2,
        handle_call/2,
        handle_cast/2,
        handle_info/2,
        code_change/3
    ]).

%%%===================================================================
%%% gen_event callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a new event handler is added to an event manager,
%% this function is called to initialize the event handler.
%%
%% @spec init(Args) -> {ok, State}
%% @end
%%--------------------------------------------------------------------
init(State) ->
    {ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever an event manager receives an event sent using
%% gen_event:notify/2 or gen_event:sync_notify/2, this function is
%% called for each installed event handler to handle the event.
%%
%% The form of the error message can be any erlang term that is accepted by
%% io:format but it is recommended that it is a simple string.
%%
%% @spec handle_event(Event, State) ->
%%                          {ok, State}
%% @end
%%--------------------------------------------------------------------
handle_event({error_report, _From, Msg}, State) ->
    gen_server:cast({global, ?EXTERNAL_LOGGER},
        {error, {node(), self()}, Msg}),
    {ok, State};
handle_event({info_report, _From, Msg}, State) ->
    gen_server:cast({global, ?EXTERNAL_LOGGER},
        {info, {node(), self()}, Msg}),
    {ok, State};
handle_event({warning_report, _From, Msg}, State) ->
    gen_server:cast({global, ?EXTERNAL_LOGGER},
        {warning, {node(), self()}, Msg}),
    {ok, State};
handle_event(Other, State) ->
    gen_server:cast({global, ?EXTERNAL_LOGGER},
        {other, {node(), self()}, Other}),
    {ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever an event manager receives a request sent using
%% gen_event:call/3,4, this function is called for the specified
%% event handler to handle the request.
%%
%% @spec handle_call(Request, State) ->
%%                   {ok, Reply, State} |
%%                   {swap_handler, Reply, Args1, State1, Mod2, Args2} |
%%                   {remove_handler, Reply}
%% @end
%%--------------------------------------------------------------------
handle_call({'EXIT', _From, Reason}, State) ->
    terminate(Reason, State);
handle_call(_Request, _State) ->
    {error, implementationNeeded}.

handle_cast(Msg, State) ->
    io:format("got cast ~p in state ~p~n", [Msg, State]).

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called for each installed event handler when
%% an event manager receives any other message than an event or a
%% synchronous request (or a system message).
%%
%% @spec handle_info(Info, State) ->
%%                         {ok, State} |
%%                         {swap_handler, Args1, State1, Mod2, Args2} |
%%                         remove_handler
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, _State) ->
    ok.
%{error, implementationNeeded}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever an event handler is deleted from an event manager, this
%% function is called. It should be the opposite of Module:init/1 and
%% do any necessary cleaning up.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(Reason, _State) ->
    chronicler:info("~w:Received terminate call.~n"
        "Reason: ~p~n",
        [?MODULE, Reason]),
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
