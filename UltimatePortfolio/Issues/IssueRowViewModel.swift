//
//  IssueRowViewModel.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 5/2/24.
//

import Foundation

extension IssueRow {
	class ViewModel: ObservableObject {
		let issue: Issue
		
		var iconOpacity: Double {
			issue.priority == 2 ? 1 : 0
		}
		
		var iconIdentifier: String {
			issue.priority == 2 ? "\(issue.issueTitle) High Priority" : ""
		}
		
		var accessibilityHint: String {
			issue.priority == 2 ? "High priority" : ""
		}
		
		init(issue: Issue) {
			self.issue = issue
		}
	}
}
