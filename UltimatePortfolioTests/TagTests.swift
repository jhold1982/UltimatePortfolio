//
//  TagTests.swift
//  UltimatePortfolioTests
//
//  Created by Justin Hold on 8/6/23.
//

import XCTest
import CoreData
@testable import UltimatePortfolio

final class TagTests: BaseTestCase {
	
	func testCreatingTagsAndIssues() {
		let targetCount = 10
		
		// MARK: - OUTER LOOP
		for _ in 0..<targetCount {
			let tag = Tag(context: managedObjectContext)
			
			// MARK: - INNER LOOP
			for _ in 0..<targetCount {
				let issue = Issue(context: managedObjectContext)
				tag.addToIssues(issue)
			}
		}
		// Tests for number of created Tags
		XCTAssertEqual(
			dataController.count(for: Tag.fetchRequest()),
			targetCount,
			"There should be \(targetCount) tags."
		)
		// Tests for number of created Issues
		XCTAssertEqual(
			dataController.count(for: Issue.fetchRequest()),
			targetCount * targetCount,
			"There should be \(targetCount * targetCount) issues."
		)
	}
	
	func testDeletingTagsDoesNotDeleteIssues() throws {
		dataController.createSampleData()
		
		let request = NSFetchRequest<Tag>(entityName: "Tag")
		let tags = try managedObjectContext.fetch(request)
		
		dataController.delete(tags[0])
		
		// Tests for number of remaining Tags after deletion
		XCTAssertEqual(
			dataController.count(for: Tag.fetchRequest()),
			4,
			"There should be 4 Tags after deleting 1 from our sample data."
		)
		
		// Tests for number of remaining Issues after Tag deletion
		XCTAssertEqual(
			dataController.count(for: Issue.fetchRequest()),
			50,
			"There should still be 50 Issuess after deleting 1 Tag from our sample data."
		)
	}
}
