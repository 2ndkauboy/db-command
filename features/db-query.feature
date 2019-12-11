Feature: Query the database with WordPress' MySQL config

  Scenario: Database querying shouldn't load any plugins
    Given a WP install
    And a wp-content/mu-plugins/error.php file:
      """
      <?php
      WP_CLI::error( "Plugin loaded." );
      """

    When I try `wp option get home`
    Then STDERR should be:
      """
      Error: Plugin loaded.
      """

    When I run `wp db query "SELECT COUNT(ID) FROM wp_users;"`
    Then STDOUT should be:
      """
      COUNT(ID)
      1
      """

  Scenario: Database querying with passed-in options
    Given a WP install

    When I run `wp db query "SELECT COUNT(ID) FROM wp_posts;" --dbuser=wp_cli_test --html`
    Then STDOUT should contain:
      """
      <TABLE
      """

    When I try `wp db query "SELECT COUNT(ID) FROM wp_posts;" --dbuser=no_such_user`
	Then the return code should not be 0
    And STDERR should contain:
      """
      Access denied
      """
    And STDOUT should be empty

  Scenario: Ensure MySQL defaults are available when as appropriate with --defaults flag
    Given a WP install

  When I try `wp db query --defaults --debug`
    Then STDERR should contain:
      """
      Debug (db): /usr/bin/env mysql --no-auto-rehash
      """

    When I try `wp db query --debug`
    Then STDERR should contain:
      """
      Debug (db): /usr/bin/env mysql --no-defaults --no-auto-rehash
      """
