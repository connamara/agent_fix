$: << File.expand_path("../../../lib", __FILE__)

require 'agent_fix/cucumber'
require 'agent_fix/cucumber/report'
require 'fix_spec/cucumber'
require 'rspec'
require 'anticipate'

Around('@inspect_all') do |scenario, block|
  old_scope = AgentFIX.include_session_level?
  AgentFIX::include_session_level = true

  #hard reset, forces logout/logon
  AgentFIX.hard_reset
  block.call
  AgentFIX::include_session_level = old_scope
end

Before('~@inspect_all') do
  AgentFIX.reset
end

FIXSpec::data_dictionary= quickfix.DataDictionary.new "features/support/FIX42.xml"

World(Anticipate)

AgentFIX.start
at_exit {AgentFIX.stop}

