//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/15/23.
//

import SwiftUI

struct ContentView: View {
	// lets us have access to issues and tags from dataController
	@EnvironmentObject var dataController: DataController
	
	
	
	
	
    var body: some View {
		List(selection: $dataController.selectedIssue) {
			ForEach(dataController.issuesForSelectedFilter()) { issue in
				IssueRow(issue: issue)
			}
			.onDelete(perform: delete)
		}
		.navigationTitle("Issues")
		.searchable(text: $dataController.filterText, prompt: "Filter issues")
    }
	func delete(_ offsets: IndexSet) {
		let issues = dataController.issuesForSelectedFilter()
		for offset in offsets {
			let item = issues[offset]
			dataController.delete(item)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView() 
    }
}
