//
//  Issue-CoreDataHelpers.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/19/23.
//

import Foundation

extension Issue {
	var issueTitle: String {
		get { title ?? "" }
		set { title = newValue }
	}
	var issueContent: String {
		get { content ?? "" }
		set { content = newValue }
	}
	var issueCreationDate: Date {
		creationDate ?? Date.now
	}
	var issueModificationDate: Date {
		modificationDate ?? Date.now
	}
	var issueTags: [Tag] {
		let result = tags?.allObjects as? [Tag] ?? []
		return result.sorted()
	}
	var issueStatus: String {
		if completed {
			return "Closed"
		} else {
			return "Open"
		}
	}
	var issueTagsList: String {
		guard let tags else { return "No tags" }
		if tags.count == 0 {
			return "No tags"
		} else {
			return issueTags.map(\.tagName).formatted()
		}
	}
	static var example: Issue {
		let controller = DataController(inMemory: true)
		let viewContext = controller.container.viewContext
		let issue = Issue(context: viewContext)
		issue.title = "Example issue"
		issue.content = "This is an example issue."
		issue.priority = 2
		issue.creationDate = .now
		return issue
	}
}

extension Issue: Comparable {
	public static func <(lhs: Issue, rhs: Issue) -> Bool {
		let left = lhs.issueTitle.localizedLowercase
		let right = rhs.issueTitle.localizedLowercase
		if left == right {
			return lhs.issueCreationDate < rhs.issueCreationDate
		} else {
			return left < right
		}
	}
}
