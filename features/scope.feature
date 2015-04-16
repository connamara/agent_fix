Feature: A demonstration of scoping capabilities in agent_fix

  Background:
    Given my agents are logged on

  Scenario: FIX42
    When I send the following FIX message from agent "my_initiator": 
    """
    8=FIX.4.235=D11=hello21=155=IBM54=140=260=20090101-17:13:06.684
    """

    Then I should receive a message on FIX of type "NewOrderSingle" with agent "my_acceptor"
    When I send the following FIX messages from agent "my_acceptor":
    """
    8=FIX.4.235=811=hello17=12337=abc39=A150=A151=020=06=014=021=155=IBM54=140=260=20090101-17:13:06.684
    8=FIX.4.235=811=hello17=12337=abc39=0150=0151=020=06=014=021=155=IBM54=140=260=20090101-17:13:06.684
    """

    Then I should receive 2 messages on FIX with agent "my_initiator"
    And the 1st message should have the following:
      | ClOrdID     | "hello"       |
      | OrderID     | "abc"         |
      | Symbol      | "IBM"         |
      | OrdStatus   | "PENDING_NEW" |

    When I inspect the 2nd message
    Then the FIX message should have the following:
      | ClOrdID     | "hello"       |
      | OrderID     | "abc"         |
      | Symbol      | "IBM"         |
      | OrdStatus   | "NEW"         |

    When I send the following FIX messages from agent "my_acceptor":
    """
    8=FIX.4.235=811=hello17=12337=abc39=4150=A151=020=06=014=021=155=IBM54=140=260=20090101-17:13:06.684
    """
    
    Then I should receive a message over FIX with agent "my_initiator"
    And the FIX message should have the following:
      | ClOrdID     | "hello"       |
      | OrderID     | "abc"         |
      | Symbol      | "IBM"         |
      | OrdStatus   | "CANCELED"    |

    When I sleep 5 seconds
    Then I should not receive any more messages with agent "my_initiator"
    And I should not receive any more messages with agent "my_initiator"


  @fix50
  Scenario: FIX50/FIXT
    When I send the following FIX message from agent "my_fix50_initiator": 
    """
    8=FIXT.1.135=D11=hello21=155=IBM54=140=260=20090101-17:13:06.684
    """

    Then I should receive a message on FIX of type "NewOrderSingle" with agent "my_fix50_acceptor"
    When I send the following FIX messages from agent "my_fix50_acceptor":
    """
    8=FIXT.1.135=811=ahoyhoy17=12337=xyzzy39=A150=A151=06=014=021=155=AAPL54=140=260=20090101-17:13:06.684
    8=FIXT.1.135=811=ahoyhoy17=12337=xyzzy39=0150=0151=06=014=021=155=AAPL54=140=260=20090101-17:13:06.684
    """

    Then I should receive 2 messages on FIX with agent "my_fix50_initiator"
    And the 1st message should have the following:
      | ClOrdID     | "ahoyhoy"     |
      | OrderID     | "xyzzy"       |
      | Symbol      | "AAPL"        |
      | OrdStatus   | "PENDING_NEW" |

    When I inspect the 2nd message
    Then the FIX message should have the following:
      | ClOrdID     | "ahoyhoy"     |
      | OrderID     | "xyzzy"       |
      | Symbol      | "AAPL"        |
      | OrdStatus   | "NEW"         |

    When I send the following FIX messages from agent "my_fix50_acceptor":
    """
    8=FIXT.1.135=811=ahoyhoy17=12337=xyzzy39=4150=A151=06=014=021=155=AAPL54=140=260=20090101-17:13:06.684
    """
    
    Then I should receive a message over FIX with agent "my_fix50_initiator"
    And the FIX message should have the following:
      | ClOrdID     | "ahoyhoy"     |
      | OrderID     | "xyzzy"       |
      | Symbol      | "AAPL"        |
      | OrdStatus   | "CANCELED"    |

    When I sleep 5 seconds
    Then I should not receive any more messages with agent "my_fix50_initiator"
    And I should not receive any more messages with agent "my_fix50_initiator"


  Scenario: scope inclusion for app messages only (default)
    When I send the following FIX message from agent "my_initiator": 
    """
    8=FIX.4.235=D11=hello21=155=IBM54=140=260=20090101-17:13:06.684
    """

    Then I should receive a message on FIX of type "NewOrderSingle" with agent "my_acceptor"
    When I send the following FIX messages from agent "my_acceptor":
    """
    8=FIX.4.235=811=hello17=12337=abc39=A150=A151=020=06=014=021=155=IBM54=140=260=20090101-17:13:06.684
    8=FIX.4.235=811=hello17=12337=abc39=0150=0151=020=06=014=021=155=IBM54=140=260=20090101-17:13:06.684
    8=FIX.4.235=811=hello17=12337=abc39=4150=A151=020=06=014=021=155=IBM54=140=260=20090101-17:13:06.684
    """
    
    Then I should receive 3 messages on FIX with agent "my_initiator"
    And the FIX messages should include a message with the following:
      | ClOrdID     | "hello"       |
      | OrderID     | "abc"         |
      | Symbol      | "IBM"         |
      | OrdStatus   | "NEW"         |


  @fix50
  Scenario: scope inclusion for app messages only (default) (FIX50/FIXT)
    When I send the following FIX message from agent "my_fix50_initiator": 
    """
    8=FIXT.1.135=D11=aloha21=155=GOOG54=140=260=20090101-17:13:06.684
    """

    Then I should receive a message on FIX of type "NewOrderSingle" with agent "my_fix50_acceptor"
    When I send the following FIX messages from agent "my_fix50_acceptor":
    """
    8=FIXT.1.135=811=aloha17=12337=xyz39=A150=A151=06=014=021=155=GOOG54=140=260=20090101-17:13:06.684
    8=FIXT.1.135=811=aloha17=12337=xyz39=0150=0151=06=014=021=155=GOOG54=140=260=20090101-17:13:06.684
    8=FIXT.1.135=811=aloha17=12337=xyz39=4150=A151=06=014=021=155=GOOG54=140=260=20090101-17:13:06.684
    """
    
    Then I should receive 3 messages on FIX with agent "my_fix50_initiator"
    And the FIX messages should include a message with the following:
      | ClOrdID     | "aloha"       |
      | OrderID     | "xyz"         |
      | Symbol      | "GOOG"        |
      | OrdStatus   | "NEW"         |

