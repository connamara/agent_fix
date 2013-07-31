agent_fix
========

Agent framework designed for FIX applications

Dependencies
------------

This project was tested using `jruby-1.7.4`.

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

### Configuration

In order to use Agent FIX, in your `env.rb` you must:

```ruby
require 'agent_fix'
```

You can define a data dictionary using FIX spec:

```ruby
FIXSpec::data_dictionary= quickfix.DataDictionary.new "path/to/FIX42.xml"
```

Configure inspection behavior to use combined admin & app messages (default is app-only):

```ruby
AgentFIX::message_scope_level = {:from_all => true}
```

### Getting Started

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

### Scoping in cucumber steps

Agent FIX comes with a few features to assist in organizing larger tests, including the ability to scope incoming messages.  As an example, taken from `features/scope.feature`, first define your scope size with the expectation to receive a certain number of messages:

```cucumber
Then I should receive 3 messages on FIX with agent "my_initiator"
```

Your scope is now defined to 3 messages.  Whenever you attempt to inspect a message by index, the locally defined scope will be used:

```cucumber
And the 2nd message should have the following:
  | ClOrdID     | "hello"       |
  | OrderID     | "abc"         |
  | Symbol      | "IBM"         |
  | OrdStatus   | "PENDING_NEW" |
```

This will attempt to inspect the second message in the local scope.  If you then said:

```cucumber
Then I should receive 4 messages on FIX with agent "my_initiator"
And the 2nd message should have the following:
  | ClOrdID     | "hello"          |
  | OrderID     | "abc"            |
  | Symbol      | "IBM"            |
  | OrdStatus   | "PENDING_CANCEL" |
```

The inspection step, `And the 2nd message should have the following` will be looking at the 5th message the agent has received since the scenario was started, or the 2nd message in the last defined scope.  The first scope was defined to have 3 messages, the second defined to have 4, which means the second scope is defined as messages #4-7.

### Scope inclusion

Scope inclusion is scope inspection without regard to order.  Say the agent received the following FIX messages:

```
8=FIX.4.2|35=8|11=hello|17=123|37=abc|39=A|150=A|151=0|20=0|6=0|14=0|21=1|55=IBM|54=1|40=2|60=20090101-17:13:06.684|
8=FIX.4.2|35=8|11=hello|17=123|37=abc|39=0|150=0|151=0|20=0|6=0|14=0|21=1|55=IBM|54=1|40=2|60=20090101-17:13:06.684|
8=FIX.4.2|35=8|11=hello|17=123|37=abc|39=4|150=A|151=0|20=0|6=0|14=0|21=1|55=IBM|54=1|40=2|60=20090101-17:13:06.684|
```

Define your scope:


```cucumber
Then I should receive 3 messages on FIX with agent "my_initiator"
```

Check for inclusion:

```cucumber
And the FIX messages should include a message with the following:
  | ClOrdID     | "hello"       |
  | OrderID     | "abc"         |
  | Symbol      | "IBM"         |
  | OrdStatus   | "NEW"         |
```

Message #2 has `39=0` (`OrdStatus=NEW`), and matches the cucumber step, so this step will pass.  If the message was first or third in the scope, the step would still pass.


Setup
-----

    bundle install

Test
----

    env JAVA_OPTS=-XX:MaxPermSize=2048m bundle exec rake cucumber
