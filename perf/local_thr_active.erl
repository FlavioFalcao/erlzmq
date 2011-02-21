#! /usr/bin/env escript
%%! -smp enable -pa ebin

main([BindTo,MessageSizeStr,MessageCountStr]) ->
    {MessageSize, _} = string:to_integer(MessageSizeStr),
    {MessageCount, _} = string:to_integer(MessageCountStr),
    zmq:start_link(),
    {ok, Socket} = zmq:socket(sub, [{subscribe, ""},{active, true}]),
    ok = zmq:bind(Socket, BindTo),
    
    {Elapsed, _} = timer:tc(fun () ->
                                    [ receive X -> X end || _I <- lists:seq(1,MessageCount) ]
                            end,[]),
    
    Throughput = MessageCount / Elapsed * 1000000,
    Megabits = Throughput * MessageSize * 8,

    io:format("message size: ~p [B]~n"
              "message count: ~p~n"
              "mean throughput: ~p [msg/s]~n"
              "mean throughput: ~p [Mb/s]~n",
              [MessageSize, MessageCount, Throughput, Megabits]).    
    
