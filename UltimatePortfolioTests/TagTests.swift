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
		for _ in 0..<targetCount {
			let tag = Tag(context: managedObjectContext)
			for _ in 0..<targetCount {
				let issue = Issue(context: managedObjectContext)
				tag.addToIssues(issue)
			}
		}
		XCTAssertEqual(
			dataController.count(for: Tag.fetchRequest()),
			targetCount,
			"There should be \(targetCount) tags."
		)
		XCTAssertEqual(
			dataController.count(for: Issue.fetchRequest()),
			targetCount * targetCount,
			"There should be \(targetCount * targetCount) issues."
		)
	}

}
