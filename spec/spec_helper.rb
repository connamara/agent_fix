require 'agent_fix'

RSpec.configure do |config|
  config.before do
    AgentFIX.reset_config
  end
end

