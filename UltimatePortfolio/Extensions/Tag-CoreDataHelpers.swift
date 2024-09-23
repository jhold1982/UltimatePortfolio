//
//  Tag-CoreDataHelpers.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/19/23.
//

import Foundation

extension Tag {
	var tagID: UUID {
		id ?? UUID()
	}

	var tagName: String {
		name ?? ""
	}

	var tagActiveIssues: [Issue] {
		let result = issues?.allObjects as? [Issue] ?? []
		return result.filter { $0.completed == false }
	}

	static var example: Tag {
		let controller = DataController(inMemory: true)
		let viewContext = controller.container.viewContext

		let tag = Tag(context: viewContext)
		tag.id = UUID()
		tag.name = "Example Tag"
		return tag
	}
}

extension Tag: Comparable {
	public static func <(lhs: Tag, rhs: Tag) -> Bool {
		let left = lhs.tagName.localizedLowercase
		let right = rhs.tagName.localizedLowercase

		if left == right {
			return lhs.tagID.uuidString < rhs.tagID.uuidString
		} else {
			return left < right
		}
	}
}
