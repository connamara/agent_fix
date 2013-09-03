require 'spec_helper'

describe AgentFIX::Configuration do
  it "inspects just app messages by default" do
    AgentFIX.include_session_level?.should be_false
  end

  it "can inspect both app and session level messages" do
    AgentFIX.include_session_level = true
    AgentFIX.include_session_level?.should be_true
  end
end
