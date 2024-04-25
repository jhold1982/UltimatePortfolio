//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/15/23.
//

import SwiftUI

struct ContentView: View {
	
	// MARK: - PROPERTIES
	@EnvironmentObject var dataController: DataController
	
	
	// MARK: - VIEW BODY
    var body: some View {
		List(selection: $dataController.selectedIssue) {
			ForEach(dataController.issuesForSelectedFilter()) { issue in
				IssueRow(issue: issue)
			}
			.onDelete(perform: delete)
		}
		.navigationTitle("Issues")
		.searchable(
			text: $dataController.filterText,
			tokens: $dataController.filterTokens,
			suggestedTokens: .constant(dataController.suggestedFilterTokens),
			prompt: "Filter issues, or type # to add tags"
		) { tag in
			Text(tag.tagName)
		}
		.toolbar(content: ContentViewToolbar.init)
    }
	
	// MARK: - FUNCTIONS
	/// Method to deleted "Issues" from DataController
	/// - Parameter offsets: Looks for that Issue's Index and deletes
	func delete(_ offsets: IndexSet) {
		let issues = dataController.issuesForSelectedFilter()
		for offset in offsets {
			let item = issues[offset]
			dataController.delete(item)
		}
	}
}

// MARK: - PREVIEWS
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView()
			.environmentObject(DataController(inMemory: true))
    }
}
