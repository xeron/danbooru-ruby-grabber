@pool
Feature: Download images by pool

  @danbooru
  Scenario: Download images from danbooru
    Given I want to download images from danbooru pool and save them using default pattern
    When I run script to download images using default saver
    Then I should see downloaded images by pool
    And I should see images in bbs file

  @konachan
  Scenario: Download images from konachan
    Given I want to download images from konachan pool and save them using id
    When I run script to download images using wget
    Then I should see downloaded images by pool
    And I should see images in bbs file

  @e621
  Scenario: Download images from e621
    Given I want to download images from e621 pool and save them using md5
    When I run script to download images using curl
    Then I should see downloaded images by pool
    And I should see images in bbs file

  @behoimi
  Scenario: Download images from behoimi
    Given I want to download images from behoimi pool and save them using url
    When I run script to download images using default saver
    Then I should see downloaded images by pool
    And I should see images in bbs file

  @yandere
  Scenario: Download images from yandere
    Given I want to download images from yandere pool and save them using url
    When I run script to download images using curl
    Then I should see downloaded images by pool
    And I should see images in bbs file
