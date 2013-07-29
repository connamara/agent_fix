require File.expand_path("../../agent_fix", __FILE__)

require 'fix_spec/builder'
require 'fix_spec/cucumber'

module FIXMessageCache
  def last_fix
    @message
  end

  def agent_index
    @agent_indexes ||= Hash.new(0)
  end

  def reset_agent_indexes
    @agent_indexes = nil
  end

  def save_agent_index agent, index
    agent_index[agent.to_sym] = index
  end

  def last_agent_index agent
    agent_index[agent.to_sym]
  end
end

World(FIXMessageCache)

Before do
  reset_agent_indexes
end

def anticipate_fix
  sleeping(AgentFIX.cucumber_sleep_seconds).seconds.between_tries.failing_after(AgentFIX.cucumber_retries).tries do
    yield
  end
end

def check_agent agent
  throw "Unknown agent #{agent}" unless AgentFIX.agents_hash.has_key?(agent.to_sym)
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

Then(/^I should receive (exactly )?(\d+)(?: FIX|fix)? messages(?: (?:on|over) FIX)?(?: of type "(.*?)")? with agent "(.*?)"$/) do |exact, count, type, agent|
  check_agent agent

  count = count.to_i

  last_index = last_agent_index(agent)
  anticipate_fix do
    messages = AgentFIX.agents_hash[agent.to_sym].messages_received

    if exact
      (messages.length - last_index).should be == count, "Expected exactly #{count} messages, but got #{messages.length - last_index}"
    else
      (messages.length - last_index).should be >= count, "Expected #{count} messages, but got #{messages.length - last_index}"
    end

    @message_scope=AgentFIX.agents_hash[agent.to_sym].messages_received.slice(last_index, last_index + count.to_i)

    unless type.nil?
      @message_scope.each do |msg|
        msg.header.get_string(35) == type
      end
    end
  end

  save_agent_index agent, last_index + count

  #if we only requested one message for the scope, inspect that message
  if count == 1
    @message = AgentFIX.agents_hash[agent.to_sym].messages_received[last_index]
  else
    @message = nil
  end
end

Then(/^I should not receive any(?: more)?(?: FIX| fix)? messages with agent "(.*?)"$/) do |agent|
  steps %Q{Then I should receive exactly 0 FIX messages with agent "#{agent}"}
end

Then(/^I should receive a(?: FIX| fix)? message(?: (?:on|over) FIX)?(?: of type "(.*?)")? with agent "(.*?)"$/) do |type, agent|
  if type.nil?
    steps %Q{Then I should receive 1 FIX messages with agent "#{agent}"}
  else
    steps %Q{Then I should receive 1 FIX messages of type "#{type}" with agent "#{agent}"}
  end
end

When(/^I inspect the (\d+)(?:.*?)(?: FIX| fix)? message$/) do |index|
  index = index.to_i-1

  @message_scope.should_not be_nil, "No message scope defined"
  @message_scope.length.should be >index, "There are only #{@message_scope.length} messages in the scope"
  @message = @message_scope[index]
end


Then(/^the (\d+)(?:.*?)(?: FIX| fix)? message should have the following:$/) do |index, table|
  table_raw ="" 
  table.raw.each do |path, val|
    table_raw << "|#{path}|#{val}|\n"
  end

  steps %Q{
When I inspect the #{index}th FIX message
Then the FIX message should have the following:
#{table_raw}
  }
end

Then(/^the(?: FIX|fix)? messages should include(?: a message with)? the following:$/) do |table|
  @message_scope.should_not be_nil, "No message scope defined"
  
  # convert table into hash & strip quotes around values
  expected = Hash.new
  table.raw.each {|key, value| expected[key] = value.chomp('"').reverse.chomp('"').reverse }
  
  found = false
  @message_scope.each do |m|
    scoped_msg = FIXSpec::Helpers.message_to_hash(m)
    found |= expected.included_in?(scoped_msg)
  end
  
  found.should be_true, "Message not included in FIX messages"

end

class Hash
  def included_in?(another)
    # another has to have all my keys...
    return false unless (keys - another.keys).empty?
    # ..and have the same value for every my key
    each do |k,v|
      return false unless v == another[k]
    end
    true
  end
end