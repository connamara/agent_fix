Feature: Simple demo for log on

Background:
  Given the agents are running

@inspect_all
Scenario: logon test with inspect all scope
    Then I should receive a message on FIX with agent "my_acceptor"
    And the FIX message type should be "Logon"
    And the fix should have the following:
      |BeginString |"FIX.4.2" |
      |SenderCompID|"ARCA"    |
      |TargetCompID|"TW"      |

    And I should receive a message on FIX of type "Logon" with agent "my_initiator"
    And the fix should have the following:
      |BeginString  |"FIX.4.2" |
      |MsgType      |"Logon"   |
      |TargetCompID |"ARCA"    |
      |SenderCompID |"TW"      |

@inspect_app
Scenario: logon test with inspect app-only scope
    Then I should not receive any more FIX messages with agent "my_initiator"
    Then I should not receive any more FIX messages with agent "my_acceptor"