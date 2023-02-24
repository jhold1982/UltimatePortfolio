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
	
	// Loads all tags with no filtering, sorting by name.
	// @FetchRequest ensures SwiftUI updates tags list automatically
	// as tags are added or removed.
	@FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
	
	var tagFilters: [Filter] {
		tags.map { tag in
			Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
		}
	}
	
    var body: some View {
		List(selection: $dataController.selectedFilter) {
			Section("Smart Filters") {
				ForEach(smartFilters) { filter in
					NavigationLink(value: filter) {
						Label(filter.name, systemImage: filter.icon)
					}
				}
			}
			Section("Tags") {
				ForEach(tagFilters) { filter in
					NavigationLink(value: filter) {
						Label(filter.name, systemImage: filter.icon)
							.badge(filter.tag?.tagActiveIssues.count ?? 0)
					}
				}
				.onDelete(perform: delete)
			}
		}
		.toolbar {
			Button {
				dataController.deleteAll()
				dataController.createSampleData()
			} label: {
				Label("Add Samples", systemImage: "flame")
			}
		}
		
    }
	func delete(_ offsets: IndexSet) {
		for offset in offsets {
			let item = tags[offset]
			dataController.delete(item)
		}
	}
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
			// This pulls from DataController and keeps previews
			// from crashing
			.environmentObject(DataController.preview)
    }
}
