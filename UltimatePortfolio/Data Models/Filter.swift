//
//  Filter.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/19/23.
//

import Foundation

/// We’re going to combine these two concepts – smart mailboxes and tags – into a single new type called Filter.
/// Each filter will have a name and an icon so we can display it on the screen,
/// along with an optional Tag instance in case we’re filtering using one of the user’s tags.

/// Alongside those three I want to add two more properties:
/// a unique identifier so we can conform to the Identifiable protocol,
/// along with a minimum creation date so we’re able to look specifically for recent issues.
struct Filter: Identifiable, Hashable {
	var id: UUID
	var name: String
	var icon: String
	var minModificationDate = Date.distantPast
	var tag: Tag?
	/// The minimum modification date is set to a date in the distant past by default,
	/// so that every issue appears in a filter unless we specifically ask for a newer date.
	/// We also have an optional Tag, which is where we’ll filter by a specific tag if requested.
	var activeIssuesCount: Int {
		tag?.tagActiveIssues.count ?? 0
	}
	/// These two constant values represent the smart mailboxes we’ll have:
	/// “All Issues” and “Recent Issues”.
	static var all = Filter(id: UUID(), name: "All Issues", icon: "tray")
	static var recent = Filter(
		id: UUID(),
		name: "Recent Issues",
		icon: "clock",
		minModificationDate: .now.addingTimeInterval(86400 * -7)
	)
	
	/// The methods added are custom Hashable and Equatable conformances,
	/// because when comparing two filters about all we care is that they have the same id property.
	/// There’s no point trying to hash the name, icon, modification date, and tag,
	/// and in fact doing so might cause odd behaviors as the tag changes over time.
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	static func ==(lhs: Filter, rhs: Filter) -> Bool {
		lhs.id == rhs.id
	}
}
