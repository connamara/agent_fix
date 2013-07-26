$: << File.expand_path("../../../lib", __FILE__)

require 'agent_fix/cucumber'
require 'fix_spec/cucumber'
require 'rspec'
require 'anticipate'

FIXSpec::data_dictionary= quickfix.DataDictionary.new "features/support/FIX42.xml"

World(Anticipate)

AgentFIX.start
at_exit {AgentFIX.stop}

Before do
  sleep(0.5)
  AgentFIX.reset
end
