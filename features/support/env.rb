$: << File.expand_path("../../../lib", __FILE__)

require 'fix_spec'
require 'fix_spec/cucumber'
require 'agent_fix/cucumber'
require 'agent_fix/cucumber/report'
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

Before('~@fix50') do
  FIXSpec::data_dictionary = quickfix.DataDictionary.new "features/support/FIX42.xml"
end

Before('@fix50') do
  FIXSpec::application_data_dictionary = FIXSpec::DataDictionary.new "features/support/FIX50SP1.xml"
  FIXSpec::session_data_dictionary = FIXSpec::DataDictionary.new "features/support/FIXT11.xml"
end

World(Anticipate)

AgentFIX.start
at_exit {AgentFIX.stop}

