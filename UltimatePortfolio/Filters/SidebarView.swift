//
//  SidebarView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/19/23.
//

import SwiftUI

struct SidebarView: View {
	
	// MARK: - PROPERTIES
	@StateObject private var viewModel: ViewModel
	let smartFilters: [Filter] = [.all, .recent]
	
	init(dataController: DataController) {
		let viewModel = ViewModel(dataController: dataController)
		_viewModel = StateObject(wrappedValue: viewModel)
	}
	
	// MARK: - VIEW BODY
    var body: some View {
		List(selection: $viewModel.dataController.selectedFilter) {
			Section("Smart Filters") {
				ForEach(smartFilters, content: SmartFilterRow.init)
			}
			Section("Tags") {
				ForEach(viewModel.tagFilters) { filter in
					UserFilterRow(
						filter: filter,
						rename: viewModel.rename,
						delete: viewModel.delete
					)
				}
				.onDelete(perform: viewModel.delete)
			}
		}
		.macFrame(minWidth: 220)
		.toolbar(content: SidebarViewToolbar.init)
		.alert("Rename tag", isPresented: $viewModel.renamingTag) {
			Button("OK", action: viewModel.completeRename)
			Button("Cancel", role: .cancel) { }
			TextField("New name", text: $viewModel.tagName)
		}
		.navigationTitle("Filters")
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
		SidebarView(dataController: .preview)
    }
}
