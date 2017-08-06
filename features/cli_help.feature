Feature: Help Command

  Scenario: Show help for existing command
    Given fizzy commandline interface
    When I provide 'help' as first argument
    And  I provide a valid command name as second argument
    Then I should see the help for that command, describing how to launch it and the commandline arguments details

  Scenario: Show error for non-existing command
    Given fizzy commandline interface
    When I provide 'help' as first argument
    And  I provide an invalid command name as second argument
    Then I should see an invalid command error message

  Scenario: Show error for missing command
    Given fizzy commandline interface
    When I provide 'help' as first argument
    And  I don't provide the command name
    Then I should see a missing command error message
