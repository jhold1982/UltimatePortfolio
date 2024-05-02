//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/15/23.
//

import SwiftUI

struct ContentView: View {
	
	// MARK: - PROPERTIES
	@StateObject var viewModel: ViewModel
	
	
	// MARK: - VIEW BODY
    var body: some View {
		List(selection: $viewModel.dataController.selectedIssue) {
			ForEach(viewModel.dataController.issuesForSelectedFilter()) { issue in
				IssueRow(issue: issue)
			}
			.onDelete(perform: viewModel.delete)
		}
		.navigationTitle("Issues")
		.searchable(
			text: $viewModel.dataController.filterText,
			tokens: $viewModel.dataController.filterTokens,
			suggestedTokens: .constant(viewModel.dataController.suggestedFilterTokens),
			prompt: "Filter issues, or type # to add tags"
		) { tag in
			Text(tag.tagName)
		}
		.toolbar(content: ContentViewToolbar.init)
    }
	
	init(dataController: DataController) {
		let viewModel = ViewModel(dataController: dataController)
		_viewModel = StateObject(wrappedValue: viewModel)
	}
}

// MARK: - PREVIEWS
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView(dataController: .preview)
			.environmentObject(DataController(inMemory: true))
    }
}
