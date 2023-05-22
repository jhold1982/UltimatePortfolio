//
//  SidebarView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/19/23.
//

import SwiftUI

struct SidebarView: View {
	@EnvironmentObject var dataController: DataController
	let smartFilters: [Filter] = [.all, .recent]
	/// Loads all tags with no filtering, sorting by name.
	/// @FetchRequest ensures SwiftUI updates tags list automatically
	/// as tags are added or removed.
	@FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
	@State private var tagToRename: Tag?
	@State private var renamingTag = false
	@State private var tagName = ""
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
    var body: some View {
		List(selection: $dataController.selectedFilter) {
			Section("Smart Filters") {
				ForEach(smartFilters, content: SmartFilterRow.init)
			}
			Section("Tags") {
				ForEach(tagFilters) { filter in
					UserFilterRow(
						filter: filter,
						rename: rename,
						delete: delete
					)
				}
				.onDelete(perform: delete)
			}
		}
		.toolbar(content: SidebarViewToolbar.init)
		.alert("Rename tag", isPresented: $renamingTag) {
			Button("OK", action: completeRename)
			Button("Cancel", role: .cancel) { }
			TextField("New name", text: $tagName)
		}
		.navigationTitle("Filters")
    }
	// MARK: this method works for swipe-to-delete
	func delete(_ offsets: IndexSet) {
		for offset in offsets {
			let item = tags[offset]
			dataController.delete(item)
		}
	}
	// MARK: this method is for deleting via context menu
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
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
			// This pulls from DataController and keeps previews from crashing
			.environmentObject(DataController.preview)
    }
}
