When(/^I sleep (\d+) seconds$/) do |for_time|
  sleep for_time.to_i
end

Given(/^the agents are running$/) do
  #nop
end



Given(/^my agents are logged on$/) do
  sleeping(AgentFIX.cucumber_sleep_seconds).seconds.between_tries.failing_after(AgentFIX.cucumber_retries).tries do
    AgentFIX.agents_hash[:my_acceptor].loggedOn?.should be_true
    AgentFIX.agents_hash[:my_initiator].loggedOn?.should be_true
  end
end

When(/^"(.*?)" sends a TestRequest with TestReqID "(.*)"$/) do |agent, value|
  msg = quickfix.Message.new
  msg.getHeader.setField(quickfix.field.MsgType.new('1'))
  msg.setField(quickfix.field.TestReqID.new(value))

  AgentFIX.agents_hash[agent.to_sym].sendToTarget(msg)
end

Then(/^"(.*?)" should receive a (TestRequest|HeartBeat) with TestReqID "(.*?)"$/) do |agent, messageType, value|
  @message = AgentFIX.agents_hash[agent.to_sym].pop

  msgType = quickfix.field.MsgType.new
  @message.getHeader.getField(msgType)
  if messageType == "TestRequest"
    msgType.getValue.should ==("1")
  else
    #heart beat
    msgType.getValue.should ==("0")
  end

  reqID = quickfix.field.TestReqID.new
  @message.getField(reqID)
  reqID.getValue.should ==(value)
end
