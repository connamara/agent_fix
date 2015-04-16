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

AgentFIX.define_initiator :my_fix50_initiator do |i|
  i.default = { ReconnectInterval: 1 }

  i.session = { BeginString:      "FIXT.1.1",
                DefaultApplVerID: "FIX.5.0SP1",
                SenderCompID:     "ARCA_FIX50",
                TargetCompID:     "TW_FIX50",
                SocketConnectPort: PORT+1 }
end

AgentFIX.define_acceptor :my_fix50_acceptor do |a|
  a.session = { BeginString:      "FIXT.1.1",
                DefaultApplVerID: "FIX.5.0SP1",
                SenderCompID:     "TW_FIX50",
                TargetCompID:     "ARCA_FIX50",
                SocketAcceptPort: PORT+1 }
end

