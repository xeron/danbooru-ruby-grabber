Feature: Download images

  Scenario: Download images from danbooru
    Given I want to download images from danbooru
    When I run script to download images
    Then I should see downloaded images
    And I should see images and tags in bbs file

  Scenario: Download images from konachan
    Given I want to download images from konachan
    When I run script to download images
    Then I should see downloaded images
    And I should see images and tags in bbs file

  Scenario: Download images from e621
    Given I want to download images from e621
    When I run script to download images
    Then I should see downloaded images
    And I should see images and tags in bbs file

  Scenario: Download images from behoimi
    Given I want to download images from behoimi
    When I run script to download images
    Then I should see downloaded images
    And I should see images and tags in bbs file

  Scenario: Download images from yandere
    Given I want to download images from yandere
    When I run script to download images
    Then I should see downloaded images
    And I should see images and tags in bbs file
