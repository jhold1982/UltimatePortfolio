//
//  SidebarViewModel.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 4/24/24.
//

import Foundation
import CoreData
import SwiftUI

extension SidebarView {
	class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
		
		// MARK: - PROPERTIES
		@Published var tagToRename: Tag?
		@Published var renamingTag = false
		@Published var tagName = ""
		@Published var tags = [Tag]()
		
		var tagFilters: [Filter] {
			tags.map { tag in
				Filter(
					id: tag.tagID,
					name: tag.tagName,
					icon: "tag",
					tag: tag
				)
			}
		}
		
		var dataController: DataController
		
		init(dataController: DataController) {
			self.dataController = dataController
			
			let request = Tag.fetchRequest()
			request.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
			
			tagsController = NSFetchedResultsController(
				fetchRequest: request,
				managedObjectContext: dataController.container.viewContext,
				sectionNameKeyPath: nil,
				cacheName: nil
			)
			
			super.init()
			tagsController.delegate = self
			
			do {
				try tagsController.performFetch()
				tags = tagsController.fetchedObjects ?? []
			} catch {
				print("Failed to fetch tags")
			}
		}
		
		private let tagsController: NSFetchedResultsController<Tag>
		
		// MARK: - FUNCTIONS
		/// <#Description#>
		/// - Parameter offsets: <#offsets description#>
		func delete(_ offsets: IndexSet) {
			for offset in offsets {
				let item = tags[offset]
				dataController.delete(item)
			}
		}
		
		func delete(_ filter: Filter) {
			guard let tag = filter.tag else { return }
			dataController.delete(tag)
			dataController.save()
		}
		
		func rename(_ filter: Filter) {
			tagToRename = filter.tag
			tagName = filter.name
			renamingTag = true
		}
		
		func completeRename() {
			tagToRename?.name = tagName
			dataController.save()
		}
		
		func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
			if let newTags = controller.fetchedObjects as? [Tag] {
				tags = newTags
			}
		}
	}
}
