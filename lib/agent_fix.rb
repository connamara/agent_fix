require 'quickfix'
require 'agent_fix/configuration'
require 'agent_fix/agent'

module AgentFIX
  extend Configuration
  extend self

  def agent_path
    "./config/fix_agents.rb"
  end

  def agents
    return @agents if @agents

    (@agents=[]).tap do
      load_agents if agent_files_loaded.empty?
    end
  end

  def agent_files_loaded
    @agent_files_loaded ||=[]
  end
  
  def load_agents path=nil
    path = File.expand_path(path || agent_path, Dir.pwd)
    return if agent_files_loaded.include? path
    agent_files_loaded << path
    load path
  end

  def define_agent(agent, &blk)
    yield agent
    agents << agent
  end

  def define_acceptor(name, &blk)
    define_agent(Agent.new(name, :acceptor), &blk)
  end

  def define_initiator(name, &blk)
    define_agent(Agent.new(name, :initiator), &blk)
  end
  
  #starts all configured agents
  def start
    raise RuntimeError, "No FIX Agents Defined" if agents.empty?

    agents.each do |a|
      a.start
    end
  end

  def stop
    agents.each {|a| a.stop}
  end

  def reset
    agents.each {|a| a.reset}
  end

  def agents_hash
    Hash[agents.map { |a| [a.name.to_sym, a]}]
  end
end


