//
//  ContentViewModel.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 5/2/24.
//

import Foundation

extension ContentView {
	
	@dynamicMemberLookup
	class ViewModel: ObservableObject {
		
		var dataController: DataController
		
		var shouldRequestReview: Bool {
			dataController.count(for: Tag.fetchRequest()) >= 5 
		}
		
		init(dataController: DataController) {
			self.dataController = dataController
		}
		
		subscript<Value>(dynamicMember keyPath: KeyPath<DataController, Value>) -> Value {
			dataController[keyPath: keyPath]
		}
		
		subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<DataController, Value>) -> Value {
			get { dataController[keyPath: keyPath] }
			set { dataController[keyPath: keyPath] = newValue }
		}
		
		// MARK: - Functions
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
