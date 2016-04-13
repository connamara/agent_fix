require File.expand_path("../../agent_fix", __FILE__)

require 'fix_spec'
require 'fix_spec/cucumber'

module FIXMessageCache
  # accessor for fix_spec
  def last_fix
    @message
  end

  def recall_agent agent
    agent = AgentFIX.agents_hash[agent.to_sym]
    throw "Unknown agent #{agent}" if agent.nil?

    agent
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

Then(/^I should receive (exactly )?(\d+)(?: FIX|fix)? messages(?: (?:on|over) FIX)?(?: of type "(.*?)")? with agent "(.*?)"$/) do |exact, count, type, agent|
  @agent = recall_agent(agent)
  count = count.to_i

  scope = []
  anticipate_fix do
    messages = @agent.messages_received :since=>@agent.bookmark

    if exact
      expect(messages.length).to eq(count), "Expected exactly #{count} messages, but got #{messages.length}"
    else
      expect(messages.length).to be >= count, "Expected #{count} messages, but got #{messages.length}"
    end
    
    scope=messages.slice(0, count)

    unless type.nil?
      unless FIXSpec::data_dictionary.nil?
        type = FIXSpec::data_dictionary.get_msg_type(type)
      end

      scope.each do |msg|
        expect(msg[:message].header.get_string(35)).to eq(type)
      end
    end
  end

  unless scope.empty?
    @agent.bookmark = scope.last[:index]+1
  end

  @message_scope=scope.collect {|m| m[:message]}

  #if we only requested one message for the scope, inspect that message
  if count == 1
    @message = @message_scope.first
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

  expect(@message_scope).not_to be_nil, "No message scope defined"
  expect(@message_scope.length).to be >index, "There are only #{@message_scope.length} messages in the scope"
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
  expect(@message_scope).not_to be_nil, "No message scope defined"
  
  table_raw ="" 
  table.raw.each do |path, val|
    table_raw << "|#{path}|#{val}|\n"
  end
  
  found = false
  error_accum = ""
  index = 1
  @message_scope.each do |m|
    @message = m
    begin
      steps %Q{
When I inspect the #{index}th FIX message
Then the FIX message should have the following:
#{table_raw}
      }
      found = true
    rescue Exception => e
      error_accum << "\n#{m.to_s.gsub!(/\001/, '|')}\n #{e}"
    end
    index += 1
  end
  
  expect(found).to be(true), "Message not included in FIX messages\n #{error_accum}"
end

Then(/^the (?:fix|FIX) messages should include a message with(?: the tag)? "(.*)"$/) do |path|
  expect(@message_scope).not_to be_nil, "No message scope defined"

  found = false
  error_accum = ""
  index = 1
  @message_scope.each do |m|
    @message = m
    begin
      steps %Q{
When I inspect the #{index}th FIX message
And the FIX message should have "#{path}"
      }
      found = true
    rescue Exception => e
      error_accum << "\n#{m.to_s.gsub!(/\001/, '|')}\n #{e}"
    end
    index += 1
  end

  expect(found).to be(true), "Tag not included in FIX messages\n #{error_accum}"
end
