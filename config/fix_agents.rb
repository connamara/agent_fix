PORT=5000
AgentFIX.session_defaults.merge! BeginString: "FIX.4.2", SocketAcceptPort: PORT, SocketConnectPort: PORT, SocketConnectHost: "localhost"

AgentFIX.define_initiator :my_initiator do |i|
  i.default ={SenderCompID: "ARCA",ReconnectInterval: 1}
  i.session ={TargetCompID:  "TW"}
end

AgentFIX.define_acceptor :my_acceptor do |a|
  a.default ={SenderCompID: "TW"}
  a.session ={TargetCompID: "ARCA"}
end


