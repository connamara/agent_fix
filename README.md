agent\_fix [![Build Status](https://travis-ci.org/connamara/agent_fix.png)](https://travis-ci.org/connamara/agent_fix)
==========

Agent framework designed for FIX applications using [quickfix-jruby](https://github.com/connamara/quickfix-jruby).

Usage
-----

### Agent Types

#### Initiator
* Connects to an address hosting a fix session (FIX Client)

#### Acceptor
* Binds on an address to host a fix session (FIX Server)


### Agent Definition

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
FIXSpec.data_dictionary= quickfix.DataDictionary.new "path/to/FIX42.xml"
```

Configure inspection behavior to use combined admin & app messages (default is app-only):

```ruby
AgentFIX.include_session_level = true
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
8=FIX.4.2|35=8|11=hello|17=123|37=abc|39=2|150=A|151=0|20=0|6=0|14=0|21=1|55=IBM|54=1|40=2|60=20090101-17:13:06.684|
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

Message #2 has `OrdStatus=NEW`, and matches the cucumber step, so this step will pass.  If the message was first or third in the scope, the step would still pass.  If, however, another scope was then defined:

```cucumber
Then I should receive a message on FIX with agent "my_initiator"
```

And an inclusion check was performed:

```cucumber
And the FIX messages should include a message with the following:
  | ClOrdID     | "hello"       |
  | OrderID     | "abc"         |
  | Symbol      | "IBM"         |
  | OrdStatus   | "NEW"         |
```

The new scope, containing one message, will contain the last FIX message `OrdStatus=CANCELED`, and not `OrdStatus=NEW` since that was consumed by the previous scope.  The second inclusion check for `OrdStatus=NEW` would then fail, since the received message was defined in a previous inspection scope.

### Identifying scoped FIX messages in failed scenarios

In a failed Agent FIX scenario, if a scope & agent were ever defined, the last defined scope & agent will print their sent & received messages, colored according to the last defined scope.  All sent messages will be colored in green, received messages prior to the current scope will be colored in green, and the current scope when the scenario failed will have its messages colored in red.

### More

Check out [features](features/) to see all the ways you can use agent_fix.

Install
-------

```shell
gem install agent_fix
```

or add the following to Gemfile:
```ruby
gem 'agent_fix'
```
and run `bundle install` from your shell.


More Information
----------------

* [Rubygems](https://rubygems.org/gems/agent_fix)
* [Issues](https://github.com/connamara/agent_fix/issues)
* [Connamara Systems](http://connamara.com)

Contributing
------------

Please see the [contribution guidelines](CONTRIBUTION_GUIDELINES.md).

Credits
-------

Contributers:

* [Chris Busbey](https://github.com/cbusbey)
* Matt Lane
* [Mike Gatny](https://github.com/mgatny)

![Connamara Systems](http://www.connamara.com/wp-content/uploads/2016/01/connamara_logo_dark.png)

agent_fix is maintained and funded by [Connamara Systems, llc](http://connamara.com).

The names and logos for Connamara Systems are trademarks of Connamara Systems, llc.

Licensing
---------

agent\_fix is Copyright © 2016 Connamara Systems, llc.

This software is available under the GPL and a commercial license.  Please see the [LICENSE](LICENSE.txt) file for the terms specified by the GPL license.  The commercial license offers more flexible licensing terms compared to the GPL, and includes support services.  [Contact us](mailto:info@connamara.com) for more information on the Connamara commercial license, what it enables, and how you can start commercial development with it.

This product includes software developed by quickfixengine.org ([http://www.quickfixengine.org/](http://www.quickfixengine.org/)). Please see the [QuickFIX Software LICENSE](QUICKFIX_LICENSE.txt) for the terms specified by the QuickFIX Software License.
