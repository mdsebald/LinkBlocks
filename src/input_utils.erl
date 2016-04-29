%%% @doc 
%%% Get and Validate Block Input values   
%%%               
%%% @end 

-module(input_utils).

-author("Mark Sebald").

-include("block_state.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([get_any_type/2, get_integer/2, get_float/2, get_boolean/2]).
-export([get_value/3, create_input_array/3]).
-export([log_error/3]).


%%
%% Get input value of any type and check for errors.
%%
-spec get_any_type(Inputs :: list(),
                   ValueName :: atom()) -> generic_input_value().

get_any_type(Inputs, ValueName) ->
  % Return true for every value
  CheckType = fun(_Value) -> true end,
  get_value(Inputs, ValueName, CheckType).

%%
%% Get an integer input value and check for errors.
%%
-spec get_integer(Inputs :: list(), 
                  ValueName :: atom()) -> integer_input_value().

get_integer(Inputs, ValueName) ->
  CheckType = fun is_integer/1,
  get_value(Inputs, ValueName, CheckType).


%%
%% Get a floating point input value and check for errors.
%%
-spec get_float(Inputs :: list(), 
                ValueName :: atom()) -> float_input_value().

get_float(Inputs, ValueName) ->
  CheckType = fun is_float/1,
  get_value(Inputs, ValueName, CheckType).
  
  
%%
%% Get a boolean input value and check for errors
%%
-spec get_boolean(Inputs :: list(), 
                  ValueName :: atom()) -> boolean_input_value().

get_boolean(Inputs, ValueName) ->
  CheckType = fun is_boolean/1,
  get_value(Inputs, ValueName, CheckType).


%%
%% Generic get input value, check for errors.
%%
-spec get_value(Inputs :: list(),
                ValueName :: atom(),
                CheckType :: fun()) -> term().
                
get_value(Inputs, ValueName, CheckType) ->
  case block_utils:get_attribute(Inputs, ValueName) of
    not_found  -> {error, not_found};
    
    {ValueName, Value, Link} ->
      case Value of
        % not_active is a valid value
        not_active -> {ok, not_active};
        
        empty ->   
          case Link of
            % if the input value is empty and the link is empty
            % treat this like a not_active value
            ?EMPTY_LINK -> {ok, not_active};
            % input is linked to another block but value is empty,
            % this is an error
            _ -> {error, bad_link}
          end;
        
        Value ->
          case CheckType(Value) of
            true  -> {ok, Value};
            false -> {error, bad_type}
          end   
      end;
    % Attribute value was not an input value  
    _ -> {error, not_input}    
  end.
  

%%
%% Create an array of inputs, with a common base ValueName plus index number
%% Set value to DefaultValue with an EMPTY LINK
%% Create an associated list of value names, to assist accessing the input values
%%
-spec create_input_array(Quant :: integer(),
                         BaseValueName :: atom(),
                         DefaultValue :: term()) -> {list(), list()}.
                         
create_input_array(Quant, BaseValueName, DefaultValue)->
  create_input_array([], [], Quant, BaseValueName, DefaultValue).                         

                         
-spec create_input_array(Inputs :: list(),
                         ValueNames :: list(),
                         Quant :: integer(),
                         BaseValueName :: atom(),
                         DefaultValue :: term()) -> list().
                              
create_input_array(Inputs, ValueNames, 0, _BaseValueName, _DefaultValue) ->
  {lists:reverse(Inputs), lists:reverse(ValueNames)};
  
create_input_array(Inputs, ValueNames, Quant, BaseValueName, DefaultValue) ->
  ValueNameStr = iolib:format("~s_~2..0d", BaseValueName, Quant),
  ValueName = list_to_atom(ValueNameStr),
  Input = {ValueName, DefaultValue, ?EMPTY_LINK},
  create_input_array([Input | Inputs], [ValueName | ValueNames], Quant - 1, 
                      BaseValueName, DefaultValue).
  
  
%%
%% Log input value error
%%
-spec log_error(Config :: list(),
                ValueName :: atom(),
                Reason :: atom()) -> {not_active, input_err}.
                  
log_error(Config, ValueName, Reason) ->
  BlockName = config_utils:name(Config),
  error_logger:error_msg("~p Invalid '~p' input value: ~p~n", 
                            [BlockName, ValueName, Reason]),
  {not_active, input_err}.
  
  
%% ====================================================================
%% Internal functions
%% ====================================================================



%% ====================================================================
%% Tests
%% ====================================================================

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

% Test input value list
test_inputs() ->
  [ {float_good, 123.45, {null, block1, value}},
    {float_bad, xyz, ?EMPTY_LINK}
    {integer_good, 12345, {null, block2, value}},
    {integer_bad, "bad", ?EMPTY_LINK},
    {boolean_good, true, ?EMPTY_LINK},
    {boolean_bad, 0.0, ?EMPTY_LINK},
    {not_active_good, not_active, ?EMPTY_LINK},
    {empty_good, empty, ?EMPTY_LINK},
    {empty_bad, empty, {knot, empty, link}},
    {not_input, 123, [test1,test2]}
  ].
  
  
get_value_test() ->
  TestInputs = test_inputs().
    


-endif.