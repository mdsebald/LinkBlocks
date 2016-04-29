%%% @doc 
%%% Get and Validate Block Config values   
%%%               
%%% @end 

-module(config_utils).

-author("Mark Sebald").

-include("block_state.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([name/1, module/1, name_module/1]).
-export([get_any_type/2, get_integer/2, get_integer_range/4]). 
-export([get_float/2, get_boolean/2]).
-export([get_value/3]).
-export([log_error/3]).

%%
%%  Get block name from Config attribute values
%%
-spec name(Config :: list() |
           block_defn() | 
           block_state()) -> atom().

name({Config, _Inputs, _Outputs, _Private}) ->
  block_utils:get_value(Config, block_name);
  
name({Config, _Inputs, _Outputs}) ->  
  block_utils:get_value(Config, block_name);
  
name(Config) ->
  block_utils:get_value(Config, block_name).

  
%%
%% Get block module from Config attribute values 
%%
-spec module(Config :: list() | 
             block_defn() | 
             block_state()) -> module().

module({Config, _Inputs, _Outputs, _Private}) ->
  block_utils:get_value(Config, block_module);
  
module({Config, _Inputs, _Outputs}) ->
  block_utils:get_value(Config, block_module);

module(Config) ->
  block_utils:get_value(Config, block_module).


%%
%%  Get block name and module from Config attribute values
%%
-spec name_module(Config :: list() |
                  block_defn() | 
                  block_state()) -> {atom(), module()}.

name_module({Config, _Inputs, _Outputs, _Private}) ->
  {block_utils:get_value(Config, block_name),
   block_utils:get_value(Config, block_module)};
  
name_module({Config, _Inputs, _Outputs}) ->  
  {block_utils:get_value(Config, block_name),
   block_utils:get_value(Config, block_module)};
                     
name_module(Config) ->
  {block_utils:get_value(Config, block_name),
   block_utils:get_value(Config, block_module)}.


%%
%% Get configuration value of any type and check for errors.
%%
-spec get_any_type(Config :: list(),
                   ValueName :: atom()) -> generic_config_value().

get_any_type(Config, ValueName) ->
  % Return true for every value
  CheckType = fun(_Value) -> true end,
  get_value(Config, ValueName, CheckType).

%%
%% Get an integer configuration value and check for errors.
%%
-spec get_integer_range(Config :: list(), 
                        ValueName :: atom(),
                        Min :: integer(),
                        Max :: integer()) -> integer_config_value().

get_integer_range(Config, ValueName, Min, Max) ->
  CheckType = fun is_integer/1,
  case get_value(Config, ValueName, CheckType) of
    {error, Reason} -> 
      {error, Reason};
    {ok, Value} ->
      if (Value < Min ) orelse (Max < Value) ->
        {error, range};
      true -> 
        {ok, Value}
      end
  end.
       

-spec get_integer(Config :: list(), 
                  ValueName :: atom()) -> integer_config_value().

get_integer(Config, ValueName) ->
  CheckType = fun is_integer/1,
  get_value(Config, ValueName, CheckType).


%%
%% Get a floating point configuration value and check for errors.
%%
-spec get_float(Config :: list(), 
                ValueName :: atom()) -> float_config_value().

get_float(Config, ValueName) ->
  CheckType = fun is_float/1,
  get_value(Config, ValueName, CheckType).
  
  
%%
%% Get a boolean configuration value and check for errors
%%
-spec get_boolean(Config :: list(), 
                  ValueName :: atom()) -> boolean_config_value().

get_boolean(Config, ValueName) ->
  CheckType = fun is_boolean/1,
  get_value(Config, ValueName, CheckType).


%%
%% Generic get configuration value, check for errors.
%%
-spec get_value(Config :: list(),
                ValueName :: atom(),
                CheckType :: fun()) -> term().
                
get_value(Config, ValueName, CheckType) ->
  case block_utils:get_attribute(Config, ValueName) of
    not_found  -> {error, not_found};
    
    {ValueName, Value} ->
      case CheckType(Value) of
        true  -> {ok, Value};
        false -> {error, bad_type}   
      end;
    % Attribute value was not a config value  
    _ -> {error, not_config}
  end.


%%
%% Log config value error
%%
-spec log_error(Config :: list(),
                ValueName :: atom(),
                Reason :: atom()) -> {not_active, config_err}.
                  
log_error(Config, ValueName, Reason) ->
  BlockName = name(Config),
  error_logger:error_msg("~p Invalid '~p' config value: ~p~n", 
                            [BlockName, ValueName, Reason]),
  {not_active, config_err}.
  
  
%% ====================================================================
%% Internal functions
%% ====================================================================



%% ====================================================================
%% Tests
%% ====================================================================

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

% Test configuration value list
test_configs() ->
  [ {float_good, 123.45},
    {float_bad, xyz}
    {integer_good, 12345},
    {integer_bad, "bad"},
    {boolean_good, true},
    {boolean_bad, 0.0},
    {not_active_good, not_active},
    {empty_good, empty},
    {empty_bad, empty, {knot, empty, link}},
    {not_config, 123, [test1,test2]}
  ].
  
  
get_value_test() ->
  TestInputs = test_inputs().
    


-endif.