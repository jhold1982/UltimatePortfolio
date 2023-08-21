//
//  UltimatePortfolioUITests.swift
//  UltimatePortfolioUITests
//
//  Created by Justin Hold on 8/21/23.
//

import XCTest

extension XCUIElement {
	
	func clear() {
		guard let stringValue = self.value as? String else {
			XCTFail("Failed to clear text in XCUIElement")
			return
		}
		let deleteString = String(
			repeating: XCUIKeyboardKey.delete.rawValue,
			count: stringValue.count
		)
		typeText(deleteString)
	}
}

final class UltimatePortfolioUITests: XCTestCase {
	var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

		app = XCUIApplication()
		app.launchArguments = ["enable-testing"]
		app.launch()
    }

    func testAppLaunchesWithNavigationBar() throws {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		XCTAssertTrue(
			app.navigationBars.element.exists,
			"There should be a navigation bar when the app launches."
		)
    }
	
	func testAppHasBasicButtonsOnLaunch() throws {
		XCTAssertTrue(
			app.navigationBars.buttons["Filters"].exists,
			"There should be a Filters button on launch."
		)
		
		XCTAssertTrue(
			app.navigationBars.buttons["Filter"].exists,
			"There should be a Filters button on launch."
		)
		
		XCTAssertTrue(
			app.navigationBars.buttons["New Issue"].exists,
			"There should be a New Issue button on launch."
		)
	}
	
	func testNoIssuesAtStart() {
		XCTAssertEqual(
			app.cells.count,
			0,
			"There should be 0 list rows initially."
		)
	}
	
	func testCreatingIssues() {
		for tapCount in 1...5 {
			app.buttons["New Issue"].tap()
			app.buttons["Issues"].tap()
			
			XCTAssertEqual(
				app.cells.count,
				tapCount,
				"There should be \(tapCount) rows in the list."
			)
		}
	}
	
	func testCreatingAndDeletingIssues() {
		for tapCount in 1...5 {
			app.buttons["New Issue"].tap()
			app.buttons["Issues"].tap()
			
			XCTAssertEqual(
				app.cells.count,
				tapCount,
				"There should be \(tapCount) rows in the list."
			)
		}
		
		for tapCount in (0...4).reversed() {
			app.cells.firstMatch.swipeLeft()
			app.buttons["Delete"].tap()
			
			XCTAssertEqual(
				app.cells.count,
				tapCount,
				"There should be \(tapCount) rows in the list."
			)
		}
	}
	
	func testEditingIssueTitleUpdatesCorrectly() {
		
		XCTAssertEqual(
			app.cells.count,
			0,
			"There should be zero rows initially."
		)
		
		app.buttons["New Issue"].tap()
		
		app.textFields["Enter the issue title here"].tap()
		app.textFields["Enter the issue title here"].clear()
		
		app.typeText("My New Issue")
		
		app.buttons["Issues"].tap()
		
		XCTAssertTrue(
			app.buttons["My New Issue"].exists,
			"A new cell called My New Issue should now exist."
		)
	}
	
	func testEditingIssuePriorityShowsIcon() {
		
		app.buttons["New Issue"].tap()
		app.buttons["Priority, Medium"].tap()
		app.buttons["High"].tap()
		app.buttons["Issues"].tap()
		
		let identifier = "New issue High Priority"
		
		XCTAssertTrue(
			app.images[identifier].exists,
			"A high-priority issue should have an icon next to it."
		)
	}
	
	func testAllAwardsShowLockedAlert() {
		
		app.buttons["Filters"].tap()
		app.buttons["Show awards"].tap()
		
		for award in app.scrollViews.buttons.allElementsBoundByIndex {
			if app.windows.element.frame.contains(award.frame) == false {
				app.swipeUp()
			}
			award.tap()
			XCTAssertTrue(
				app.alerts["Locked"].exists,
				"There should be a Locked Alert showing for each award."
			)
			app.buttons["OK"].tap()
		}
	}
}
