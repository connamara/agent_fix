$: << File.expand_path("../../../lib", __FILE__)

require 'agent_fix/cucumber'
require 'rspec'
require 'anticipate'

World(Anticipate)

AgentFIX.start
at_exit {AgentFIX.stop}

Before do
  sleep(0.5)
  AgentFIX.reset
end
