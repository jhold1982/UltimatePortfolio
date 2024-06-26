//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/15/23.
//

import SwiftUI

struct ContentView: View {
	
	// MARK: - Properties
	@StateObject var viewModel: ViewModel
	
	
	// MARK: - View Body
    var body: some View {
		List(selection: $viewModel.selectedIssue) {
			ForEach(viewModel.dataController.issuesForSelectedFilter()) { issue in
				IssueRow(issue: issue)
			}
			.onDelete(perform: viewModel.delete)
		}
		.navigationTitle("Issues")
		.searchable(
			text: $viewModel.filterText,
			tokens: $viewModel.filterTokens,
			suggestedTokens: .constant(viewModel.suggestedFilterTokens),
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

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView(dataController: .preview)
			.environmentObject(DataController(inMemory: true))
    }
}
