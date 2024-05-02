//
//  ContentViewModel.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 5/2/24.
//

import Foundation

extension ContentView {
	
	class ViewModel: ObservableObject {
		
		var dataController: DataController
		
		init(dataController: DataController) {
			self.dataController = dataController
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
	
	
}
