Feature: Display a list of articles I have favourited this week	
	I would like a list of articles I have favourited this week
	As a user of pocket
	So that I can blog about them

    Scenario: I enter invalid pocket credentials
        Given that I enter invalid pocket credentials
        When I request a list of articles
        Then I get an error response
        
	Scenario: I have favourited articles this week
		Given that I have a pocket account
		And I have favourited articles this week
		When I request my list of articles
		Then I get a resonse containing a list of favourited articles
		
	Scenario: I have not favourited articles this week
        Given that I have a pocket account
        And I have not favourited articles this week
        When I request my list of articles
        Then I get an empty response
        
    Scenario: I have not read any articles this week
        Given that I have a pocket account
        And I have not read any articles this week
        When I request my list of articles
        Then I get an empty response
        