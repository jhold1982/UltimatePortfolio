//
//  Issue-CoreDataHelpers.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/19/23.
//

import Foundation

// If I want to work around Core Data’s optionality in a safer, more maintainable way,
// I nearly always prefer to do so using extensions that wrap up all the nil coalescing work in one place.

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
	
	// I've added a static example property that creates an example item for SwiftUI previewing purposes.
	// This can build on the inMemory initializer for DataController, so the examples are only temporary:
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

// That’s similar to the work we were doing in SidebarView, with two important changes:

// We now have setters and getters for several properties, which allows us to modify them directly.
// All the optionals are resolved in one place, here in this extension, rather than polluting the rest of our project.

// There’s no performance difference because ultimately reading the values happens using the same code,
// but it is much nicer to work with and that counts for a lot.

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
