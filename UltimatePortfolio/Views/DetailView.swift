//
//  DetailView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/19/23.
//

import SwiftUI

struct DetailView: View {
	
	@EnvironmentObject var dataController: DataController
	
    var body: some View {
		VStack {
			if let issue = dataController.selectedIssue {
				IssueView(issue: issue)
			} else {
				NoIssueView()
			}
		}
		.navigationTitle("Issue")
		.navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
