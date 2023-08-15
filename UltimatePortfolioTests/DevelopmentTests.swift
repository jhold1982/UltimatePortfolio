//
//  DevelopmentTests.swift
//  UltimatePortfolioTests
//
//  Created by Justin Hold on 8/15/23.
//

import XCTest
import CoreData
@testable import UltimatePortfolio

final class DevelopmentTests: BaseTestCase {

	func testSampleDataCreationWorks() {
		dataController.createSampleData()
		
		XCTAssertEqual(
			dataController.count(for: Tag.fetchRequest()),
			5,
			"There should be 5 sample tags."
		)
		
		XCTAssertEqual(
			dataController.count(for: Issue.fetchRequest()),
			50,
			"There should be 50 sample issues."
		)
	}
	
	func testDeleteAllDeletesEverything() {
		dataController.createSampleData()
		dataController.deleteAll()
		
		XCTAssertEqual(
			dataController.count(for: Tag.fetchRequest()),
			0,
			"deleteAll() should leave zero Tags."
		)
		
		XCTAssertEqual(
			dataController.count(for: Issue.fetchRequest()),
			0,
			"deleteAll() should leave zero Issues."
		)
	}
	
	func testNewTagsHaveNoIssues() {
		let tag = Tag.example
		
		XCTAssertEqual(
			tag.issues?.count,
			0,
			"The example tag should have zero issues."
		)
	}
	
	func testNewExampleIssueIsHighPriority() {
		let issue = Issue.example
		
		XCTAssertEqual(
			issue.priority,
			2,
			"The example issue should be high priority."
		)
	}

}
