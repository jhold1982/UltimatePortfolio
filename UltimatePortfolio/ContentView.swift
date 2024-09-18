//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/15/23.
//

import SwiftUI

struct ContentView: View {
	
	// MARK: - Properties
	@Environment(\.requestReview) var requestReview
	@StateObject var viewModel: ViewModel
	
	private let newIssueActivity = "com.leftHandedApps.UltimatePortfolio.newIssue"
	
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
		.onAppear(perform: askForReview)
		.onOpenURL(perform: viewModel.openURL)
		.userActivity(newIssueActivity) { activity in
			#if !os(macOS)
			activity.isEligibleForPrediction = true
			#endif
			activity.title = "New Issue"
		}
		.onContinueUserActivity(
			newIssueActivity,
			perform: resumeActivity
		)
    }
	
	// MARK: - Initializer
	init(dataController: DataController) {
		let viewModel = ViewModel(dataController: dataController)
		_viewModel = StateObject(wrappedValue: viewModel)
	}
	
	// MARK: - Functions
	func askForReview() {
		if viewModel.shouldRequestReview {
			requestReview()
		}
	}
	
	func resumeActivity(_ userActivity: NSUserActivity) {
		viewModel.dataController.newIssue()
	}
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView(dataController: .preview)
			.environmentObject(DataController(inMemory: true))
    }
}
