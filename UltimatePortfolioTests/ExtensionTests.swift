//
//  ExtensionTests.swift
//  UltimatePortfolioTests
//
//  Created by Justin Hold on 8/16/23.
//

import XCTest
import CoreData
@testable import UltimatePortfolio

final class ExtensionTests: BaseTestCase {

	func testIssueTitleUnwrap() {
		// Given
		let issue = Issue(context: managedObjectContext)
		
		// When
		issue.title = "Example issue"
		
		// Then
		XCTAssertEqual(
			issue.issueTitle,
			"Example issue",
			"Changing title should also change issueTitle."
		)
		
		// When
		issue.issueTitle = "Updated issue"
		
		// Then
		XCTAssertEqual(
			issue.title,
			"Updated issue",
			"Changing issueTitle should also change title."
		)
	}
	
	func testIssueContentUnwrap() {
		
		let issue = Issue(context: managedObjectContext)
		
		issue.content = "Example issue"
		XCTAssertEqual(
			issue.issueContent,
			"Example issue",
			"Changing content should also change issueContent"
		)
		
		issue.issueContent = "Updated issue"
		XCTAssertEqual(
			issue.issueContent,
			"Updated issue",
			"Changing issueContent should also change content."
		)
	}
	
	func testIssueTagsUnwrap() {
		let tag = Tag(context: managedObjectContext)
		let issue = Issue(context: managedObjectContext)
		
		XCTAssertEqual(
			issue.issueTags.count,
			0,
			"A new issue should have no tags."
		)
		
		issue.addToTags(tag)
		XCTAssertEqual(
			issue.issueTags.count,
			1,
			"Adding 1 tag to an issue should result in issueTags having count 1."
		)
	}
	
	func testIssueTagsList() {
		let tag = Tag(context: managedObjectContext)
		let issue = Issue(context: managedObjectContext)
		
		tag.name = "My Tag"
		issue.addToTags(tag)
	}
	
	func testIssueSortingIsStable() {
		let issue1 = Issue(context: managedObjectContext)
		issue1.title = "B Issue"
		issue1.creationDate = .now
		
		let issue2 = Issue(context: managedObjectContext)
		issue2.title = "B Issue"
		issue2.creationDate = .now.addingTimeInterval(1)
		
		let issue3 = Issue(context: managedObjectContext)
		issue3.title = "A Issue"
		issue3.creationDate = .now.addingTimeInterval(100)
		
		let allIssues = [issue1, issue2, issue3]
		let sorted = allIssues.sorted()
		
		XCTAssertEqual(
			[issue3, issue1, issue2],
			sorted,
			"Sorting issue arrays should use name then creation date."
		)
	}
	
	func testTagIDUnwrap() {
		let tag = Tag(context: managedObjectContext)

		tag.id = UUID()
		XCTAssertEqual(
			tag.tagID,
			tag.id,
			"Changing id should also change tagID."
		)
	}
	
	func testTagNameUnwrap() {
		let tag = Tag(context: managedObjectContext)
		
		tag.name = "Example tag"
		XCTAssertEqual(
			tag.tagName,
			"Example tag",
			"Changing name should also change tagName."
		)
	}
	
	func testTagActiveIssues() {
		let tag = Tag(context: managedObjectContext)
		let issue = Issue(context: managedObjectContext)
		
		XCTAssertEqual(
			tag.tagActiveIssues.count,
			0,
			"A new tag should have 0 active issues."
		)
		
		tag.addToIssues(issue)
		XCTAssertEqual(
			tag.tagActiveIssues.count,
			1,
			"A new tag with 1 new issue should have 1 active issues."
		)
		
		issue.completed = true
		XCTAssertEqual(
			tag.tagActiveIssues.count,
			0,
			"A new tag with 1 completed issue should have 0 active issues."
		)
	}
	
	func testTagSortingIsStable() {
		let tag1 = Tag(context: managedObjectContext)
		tag1.name = "B tag"
		tag1.id = UUID()
		
		let tag2 = Tag(context: managedObjectContext)
		tag2.name = "B tag"
		tag2.id = UUID(uuidString: "FFFFFFFF-1A8F-465F-A826-D4DFA0F9AC30")
		
		let tag3 = Tag(context: managedObjectContext)
		tag3.name = "A tag"
		tag3.id = UUID()
		
		let allTags = [tag1, tag2, tag3]
		let sortedTags = allTags.sorted()
		
		XCTAssertEqual(
			[tag3, tag1, tag2],
			sortedTags,
			"Sorted tag array should use name first then UUID."
		)
	}
	
	func testBundleDecodingAwards() {
		let awards = Bundle.main.decode("Awards.json", as: [Award].self)
		
		XCTAssertFalse(
			awards.isEmpty,
			"Awards.json should decode to a non-empty array."
		)
	}
	
	func testDecodingString() {
		let bundle = Bundle(for: ExtensionTests.self)
		let data = bundle.decode("DecodableString.json", as: String.self)
		
		XCTAssertEqual(
			data,
			"The wonder is, not that the field of stars is so vast, but that man has measured it.",
			"The string must match DecodableString.json"
		)
	}
	
	func testDecodingDictionary() {
		let bundle = Bundle(for: ExtensionTests.self)
		let data = bundle.decode("DecodableDictionary.json", as: [String: Int].self)
		
		XCTAssertEqual(
			data.count,
			3,
			"There should be 3 items decoded from DecodableDictionary.json."
		)
		
		XCTAssertEqual(
			data["One"],
			1,
			"The dictionary should contain the value 1 for the key One."
		)
		
		XCTAssertEqual(
			data["Two"],
			2,
			"The dictionary should contain the value 2 for the key Two."
		)
		
		XCTAssertEqual(
			data["Three"],
			3,
			"The dictionary should contain the value 3 for the key Three."
		)
	}
}
