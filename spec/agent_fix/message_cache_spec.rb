require 'spec_helper'

describe AgentFIX::MessageCache do
  it "is basically a read-only queue"  do
    cache = AgentFIX::MessageCache.new
    cache.add_message "1"
    cache.add_message "2"
    cache.add_message "3"

    msgs = cache.messages
    msgs.should == ["1","2","3"]

    cache.clear!
    msgs.should == ["1","2","3"]
  end
end
