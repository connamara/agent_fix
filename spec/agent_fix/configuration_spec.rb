require 'spec_helper'

describe AgentFIX::Configuration do
  it "inspects just app messages by default" do
    expect(AgentFIX.include_session_level?).to be(false)
  end

  it "can inspect both app and session level messages" do
    AgentFIX.include_session_level = true
    expect(AgentFIX.include_session_level?).to be(true)
  end
end
