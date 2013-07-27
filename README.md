agent_fix
========

Agent framework designed for FIX applications

Dependencies
------------

This project was tested using `jruby-1.7.4`.
The project uses `fix_spec` for FIX inspection needs, and `fix_spec` tags may be used (e.g. @with_data_dictionary)

Agent Types
-----------

### Initiator

* Binds on an address

### Acceptor

* Connects to an address

Agent Definition
----------------

Inside your project, declare agents and connection information inside ```config/fix_agents.rb``` like so:

```ruby
PORT=5000
AgentFIX.session_defaults.merge! BeginString: "FIX.4.2", SocketAcceptPort: PORT, SocketConnectPort: PORT, SocketConnectHost: "localhost"

AgentFIX.define_acceptor :my_acceptor do |a|
  a.default ={SenderCompID: "TW"}
  a.session ={TargetCompID: "ARCA"}
end

AgentFIX.define_initiator :my_initiator do |i|
  i.default ={SenderCompID: "ARCA"}
  i.session ={TargetCompID:  "TW"}
end
```

Usage
-----

In order to use Agent FIX, in your `env.rb` you must:

```ruby
require 'agent_fix'
```

You can define a data dictionary using FIX spec:

```ruby
FIXSpec::data_dictionary= quickfix.DataDictionary.new "path/to/FIX42.xml"
```

Start the FIX agents:

```ruby
AgentFIX.start
at_exit {AgentFIX.stop}
```

When using cucumber, to clear message caches before each scenario:

```ruby
Before do
  sleep(0.5)
  AgentFIX.reset
end
```

Setup
-----

    bundle install

Test
----

    env JAVA_OPTS=-XX:MaxPermSize=2048m bundle exec rake cucumber
