$: << File.expand_path("../../../lib", __FILE__)

require 'agent_fix/cucumber'
require 'fix_spec/cucumber'
require 'rspec'
require 'anticipate'

Around('@inspect_all') do |scenario, block|
  old_scope = AgentFIX::message_scope_level
  AgentFIX::message_scope_level= {:from_all => true}
  block.call
  AgentFIX::message_scope_level= old_scope
end

Around('@inspect_app') do |scenario, block|
  old_scope = AgentFIX::message_scope_level
  AgentFIX::message_scope_level= {:from_all => false}
  block.call
  AgentFIX::message_scope_level= old_scope
end

FIXSpec::data_dictionary= quickfix.DataDictionary.new "features/support/FIX42.xml"

World(Anticipate)

AgentFIX.start
at_exit {AgentFIX.stop}

Before do
  sleep(0.5)
  AgentFIX.reset
end
