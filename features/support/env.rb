$: << File.expand_path("../../../lib", __FILE__)

require 'agent_fix/cucumber'
require 'agent_fix/cucumber/report'
require 'fix_spec/cucumber'
require 'rspec'
require 'anticipate'

Around('@inspect_all') do |scenario, block|
  old_scope = AgentFIX.include_session_level?
  AgentFIX::include_session_level = false

  #hard reset, forces logon
  AgentFIX.stop
  sleep(1)
  AgentFIX.start
  block.call
  AgentFIX::include_session_level = old_scope
end

Before do
  sleep(0.5)
  AgentFIX.reset
end

FIXSpec::data_dictionary= quickfix.DataDictionary.new "features/support/FIX42.xml"

World(Anticipate)

AgentFIX.start
at_exit {AgentFIX.stop}

