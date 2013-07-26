require File.expand_path("../../agent_fix", __FILE__)

require 'fix_spec/builder'
require 'fix_spec/cucumber'

module FIXMessageCache
  def last_fix
    @message
  end
end

World(FIXMessageCache)

def anticipate_fix
  sleeping(AgentFIX.cucumber_sleep_seconds).seconds.between_tries.failing_after(AgentFIX.cucumber_retries).tries do
    yield
  end
end

When(/^I send the following FIX message(?:s)? from agent "(.*?)":$/) do |agent, fix|
  messages = fix.split("\n")

  messages.each do |msg|
    steps %Q{
Given the following fix message:
"""
#{msg}  
"""
}
    
    AgentFIX.agents_hash[agent.to_sym].sendToTarget(FIXSpec::Builder.message)
  end
end

Then(/^I should receive (\d+) messages on FIX of type "(.*?)" with agent "(.*?)"$/) do |count, type, agent|
  throw "Unknown agent #{agent}" unless AgentFIX.agents_hash.has_key?(agent.to_sym)
  anticipate_fix do
    @messages=AgentFIX.agents_hash[agent.to_sym].messages_received.find_all do |msg|
       msg.header.get_string(35) == type
    end

    @messages.length.should ==(count.to_i)
  end
end

Then(/^the (\d+)(?:.*?) message should have the following:$/) do |index, table|
  index = index.to_i-1

  @messages.should_not be_nil
  @messages.length.should >(index)
  @message = @messages[index]

  table_raw ="" 
  table.raw.each do |path, val|
    table_raw << "|#{path}|#{val}|\n"
  end

  puts table_raw

  steps %Q{
Then the FIX message should have the following:
#{table_raw}
  }
end


Then(/^I should( not)? receive a (?:message|request|response) on (?:FIX|fix|Fix)(?: (?:of|with) type "(.*?)")? with agent "(.*?)"$/) do |negative, msgType, agent|
  throw "Unknown agent #{agent}" unless AgentFIX.agents_hash.has_key?(agent.to_sym)

  anticipate_fix do
    @message=AgentFIX.agents_hash[agent.to_sym].messages_received.last

    if negative
      break if @message.nil?
    else
      @message.should_not be_nil
    end

    if msgType.nil?
      if negative
        @message.should be_nil
      else
        @message.should_not be_nil
      end

      break
    end

    if negative
      step %(the FIX message type should not be "#{msgType}")
    else
      step %(the FIX message type should be "#{msgType}")
    end
  end
end
