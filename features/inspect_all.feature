@inspect_all
Feature: A simple test request example to demonstrate agent_fix scoping on all message types, including session level

Scenario Outline: Basic TestRequest
    Outline demonstrates that both agents can send/receive session messages

  Given the agents are running
  Then I should receive a message on FIX of type "Logon" with agent "my_acceptor"
  Then I should receive a message on FIX of type "Logon" with agent "my_initiator"


  When "<sender>" sends a TestRequest with TestReqID "<req>"
  And I sleep 5 seconds
  Then "<receiver>" should receive a TestRequest with TestReqID "<req>"
  And "<sender>" should receive a HeartBeat with TestReqID "<req>"

  When I send the following FIX message from agent "<sender>": 
  """
  8=FIX.4.235=D11=hello21=155=IBM54=140=260=20090101-17:13:06.684
  """
  Then I should receive a message on FIX of type "NewOrderSingle" with agent "<receiver>"


Examples:
      |sender       | receiver      | req   |
      |my_initiator | my_acceptor   | hello |
      |my_acceptor  | my_initiator  | world |


@fix50
Scenario Outline: Basic TestRequest
    Outline demonstrates that both agents can send/receive session messages

  Given the agents are running
  Then I should receive a message on FIX of type "Logon" with agent "my_fix50_acceptor"
  Then I should receive a message on FIX of type "Logon" with agent "my_fix50_initiator"


  When "<sender>" sends a TestRequest with TestReqID "<req>"
  And I sleep 5 seconds
  Then "<receiver>" should receive a TestRequest with TestReqID "<req>"
  And "<sender>" should receive a HeartBeat with TestReqID "<req>"

  When I send the following FIX message from agent "<sender>": 
  """
  8=FIXT.1.135=D11=hello21=155=IBM54=140=260=20090101-17:13:06.684
  """
  Then I should receive a message on FIX of type "NewOrderSingle" with agent "<receiver>"


Examples:
      |sender             | receiver            | req   |
      |my_fix50_initiator | my_fix50_acceptor   | hola  |
      |my_fix50_acceptor  | my_fix50_initiator  | mundo |
