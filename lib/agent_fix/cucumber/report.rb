class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def pink
    colorize(35)
  end
  
  def white
    colorize(37)
  end
  
  def blue
    colorize(34)
  end
  
  def magenta
    colorize(35)
  end
  
  def cyan
    colorize(36)
  end
end

After do |scenario|
  if scenario.failed? and !last_agent.nil?
  
    agent = AgentFIX.agents_hash[last_agent.to_sym]
  
    STDERR.puts "\nMessages for ".yellow + last_agent.to_s.white + ": ".yellow
    
    last_index = last_agent_index(last_agent)
    scope_size = last_scope_size(last_agent)
    
    all_messages = agent.messages_received(:app_only=>false)
    received_messages = agent.messages_received
    scoped_messages = received_messages.slice(last_index.to_i - scope_size.to_i, last_index) || []
    
    agent.messages_sent.each do |msg|
      STDERR.puts "\tsent\t" + msg.to_s.gsub!(/\001/, '|').green
    end
    
    STDERR.puts
    
    all_messages.each do |msg|
      if !scoped_messages.include?(msg)
        STDERR.puts "\trecv\t" + msg.to_s.gsub!(/\001/, '|').green
      else
        STDERR.puts "\trecv\t" + msg.to_s.gsub!(/\001/, '|').red
      end
    end
  end
end
