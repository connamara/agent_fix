Feature: A simple test request example to demonstrate agent_fix

Background:
    Given my agents are logged on

Scenario Outline: Basic TestRequest
    Outline demonstrates that both agents can send/receive

  When "<sender>" sends a TestRequest with TestReqID "<req>"
  And I sleep 5 seconds
  Then "<receiver>" should receive a TestRequest with TestReqID "<req>"
  And "<sender>" should receive a HeartBeat with TestReqID "<req>"

Examples:
      |sender       | receiver      | req   |
      |my_initiator | my_acceptor   | hello |
      |my_acceptor  | my_initiator  | world |
