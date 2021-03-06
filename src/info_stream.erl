-module(info_stream).
-export([get_info/1, process_get_info/2]).

get_info(MessageID) ->
io:format(MessageID),
P = spawn(info_stream, process_get_info, [self(), MessageID]),
	receive
		{SubjectBin, MessageBin, UpdateAtBin, P} ->
	 		exit(P, kill),
			{SubjectBin, MessageBin, UpdateAtBin};
		{"ERROR", P} ->
			{<<"">>, <<"">>, <<"">>}
	after 
	 	10000 ->
	 		io:format("Error request"),
	 		exit(P, kill),
			{<<"">>, <<"">>, <<"">>} 
	end.

%% Stream Process to getting Info
process_get_info(Parent, MessageID) ->
io:format(MessageID),
 	case hackney:request(get, lists:append(["http://api.vide.me/file/messageinfo/?",
											"messageid=", MessageID]), 
																[], <<>>, [{pool, default}]) of
        {ok, Status, RespHeaders, Client} ->
            case Status of
                200 ->
                	io:format("Request OK"),
                	{ok, JsonBody} = hackney:body(Client),
                	io:format(JsonBody),
                	DecodeJSON = jiffy:decode(JsonBody),
	            	SubjectBin   = ej:get({"results", 1, "Subject"},   DecodeJSON),
					MessageBin   = ej:get({"results", 1, "Message"},   DecodeJSON),
					UpdateAtBin = ej:get({"results", 1, "updateAt"}, DecodeJSON),
					Parent ! {SubjectBin, MessageBin, UpdateAtBin, self()};
                _   ->
                    Parent ! {"ERROR", self()}
            end;                                               
        {error, Reason} ->
        	io:format(Reason),
        	Parent ! {Reason, self()}
    end.
