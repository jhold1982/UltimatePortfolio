//
//  IssueRow.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/24/23.
//

import SwiftUI

struct IssueRow: View {
	
	// MARK: - PROPERTIES
	@EnvironmentObject var dataController: DataController
	@StateObject var viewModel: ViewModel
	
	
	// MARK: - VIEW BODY
    var body: some View {
		NavigationLink(value: viewModel.issue) {
			HStack {
				Image(systemName: "exclamationmark.circle")
					.imageScale(.large)
					.opacity(viewModel.iconOpacity)
					.accessibilityIdentifier(viewModel.iconIdentifier)
				VStack(alignment: .leading) {
					Text(viewModel.issue.issueTitle)
						.font(.headline)
						.lineLimit(1)
					Text(viewModel.issue.issueTagsList)
						.foregroundStyle(.secondary)
						.lineLimit(1)
				}
				Spacer()
				VStack(alignment: .trailing) {
					Text(viewModel.issue.issueFormattedCreationDate)
						.accessibilityLabel(viewModel.issue.issueCreationDate.formatted(
							date: .abbreviated,
							time: .omitted)
						)
						.font(.subheadline)
					if viewModel.issue.completed {
						Text("CLOSED")
							.font(.body.smallCaps())
					}
				}
				.foregroundStyle(.secondary)
			}
		}
		.accessibilityHint(viewModel.accessibilityHint)
		.accessibilityIdentifier(viewModel.issue.issueTitle)
    }
	
	init(issue: Issue) {
		let viewModel = ViewModel(issue: issue)
		_viewModel = StateObject(wrappedValue: viewModel)
	}
}

struct IssueRow_Previews: PreviewProvider {
    static var previews: some View {
		IssueRow(issue: .example)
    }
}
