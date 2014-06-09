-module(info_stream).
-export([get_info/2]).

get_info(Parent, Filename) ->
 	case hackney:request(get, "http://api.vide.me/file/info/?file=922b906ef5c7b642", [], <<>>, [{pool, default}]) of
        {ok, Status, RespHeaders, Client} ->
            case Status of
                200 ->
                	io:format("Request OK"),
                	{ok, JsonBody} = hackney:body(Client),
                	io:format(JsonBody),
                	DecodeJSON = jiffy:decode(JsonBody),
	            	Json = ej:get({"results"}, DecodeJSON),
	            	io:format(Json),
	            	Subject = "",
	            	%%io:format( lists:flatten(UserJSON)),
	            	%%{_UN, Subject}   = lists:keyfind(<<"Subject">>, 1, UserJSON),
	            	case Subject == undefined of
	            		true  -> 
	            			Subject = ""
	            	end,

                   	Parent ! {Subject, self()};
                _   ->
                    Parent ! {"ERROR", self()}
            end;                                               
        {error, Reason} ->
        	io:format(Reason),
        	Parent ! {Reason, self()}
    end.