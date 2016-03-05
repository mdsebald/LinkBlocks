%%% @doc 
%%% Block Type: Counter
%%% Description: Count number of times boolean input value changes state  
%%%               
%%% @end 

-module(block_counter).

-author("Mark Sebald").

-include("../block_state.hrl"). 

%% ====================================================================
%% API functions
%% ====================================================================
-export([create/1, create/3, create/5, initialize/1, execute/1, delete/1]).


type_name()-> counter.  

version() -> "0.1.0".   

%%  
%% Create a set of block attributes for this block type.  
%% Init attributes are used to override the default attribute values
%% and to add attributes to the lists of default attributes
%%
-spec create(BlockName :: atom()) -> block_state().

create(BlockName) -> create(BlockName, [], [], [], []).
   
create(BlockName, InitConfig, InitInputs) -> create(BlockName, InitConfig, InitInputs, [],[]).

create(BlockName, InitConfig, InitInputs, InitOutputs, InitPrivate)->

    io:format("Creating: ~p Type: ~p~n", [BlockName, type_name()]),
     
    %% Update Default Config, Input, Output, and Private attribute values 
    %% with the initial values passed into this function.
    %%
    %% If any of the intial attributes do not already exist in the 
    %% default attribute lists, merge_attribute_lists() will create them.
    %% (This is useful for block types where the number of attributes is not fixed)
    
    Config = block_utils:merge_attribute_lists(default_configs(BlockName), InitConfig),
    Inputs = block_utils:merge_attribute_lists(default_inputs(), InitInputs), 
    Outputs = block_utils:merge_attribute_lists(default_outputs(), InitOutputs),
    Private = block_utils:merge_attribute_lists(default_private(), InitPrivate),

    % This is the block state, 
	{BlockName, ?MODULE, Config, Inputs, Outputs, Private}.

%%
%% Initialize block values before starting execution
%% Perform any setup here as needed before starting execution
%%
-spec initialize(block_state()) -> block_state().

initialize({BlockName, BlockModule, Config, Inputs, Outputs, Private}) ->
    	
    % Perform block type specific initializations here, and update the state variables
    NewOutputs = Outputs,
    NewPrivate = Private,
    
    % Perform initial block execution
	{BlockName, BlockModule, Config, Inputs, NewOutputs, NewPrivate}.


%%
%%  Execute the block specific functionality
%%
-spec execute(block_state()) -> block_state().

execute({BlockName, BlockModule, Config, Inputs, Outputs, Private}) ->

    % Perform block type specific actions here, 
    % read input value(s) calculate new outut value(s)
    % set block output status value
    
    NewOutputs = Outputs,
    NewPrivate = Private,

    {BlockName, BlockModule, Config, Inputs, NewOutputs, NewPrivate}.


%% 
%%  Delete the block
%%	
-spec delete(block_state()) -> block_state().

delete({BlockName, BlockModule, Config, Inputs, Outputs, Private}) -> 
    % Perform any block type specific delete functionality here
    {BlockName, BlockModule, Config, Inputs, Outputs, Private}.


%% ====================================================================
%% Internal functions
%% ====================================================================

default_configs(BlockName) -> 
    block_utils:merge_attribute_lists(block_common:configs(BlockName, type_name(), version()), 
                            [
                                {trigger, false_true}  %Trigger count on any_change, true_false, or false_true transition
                            ]). 
 
default_inputs() -> 
     block_utils:merge_attribute_lists(block_common:inputs(),
                            [
                               {input, empty, ?EMPTY_LINK},
                               {inital_value, 0, ?EMPTY_LINK},
                               {final_value, 9, ?EMPTY_LINK}
                            ]). 
                            
default_outputs() -> 
        block_utils:merge_attribute_lists(block_common:outputs(),
                            [
                              {carry, not_active, []}
                            ]). 
                            
default_private() -> 
        block_utils:merge_attribute_lists(block_common:private(),
                            [
                               {last_input, empty}
                            ]).
