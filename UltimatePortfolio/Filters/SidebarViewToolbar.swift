//
//  SidebarViewToolbar.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 5/22/23.
//

import SwiftUI

struct SidebarViewToolbar: View {
	
	// MARK: - Properties
	@EnvironmentObject var dataController: DataController
	@State private var showingAwards = false
	@State private var showingStore = false
	
	// MARK: - View Body
    var body: some View {
		
		Button(action: tryNewTag) {
			Label("Add tag", systemImage: "plus")
		}
		.sheet(isPresented: $showingStore, content: StoreView.init)
		.help("Add tag")
		
		Button {
			showingAwards.toggle()
		} label: {
			Label("Show awards", systemImage: "rosette")
		}
		.sheet(isPresented: $showingAwards, content: AwardsView.init)
		.help("Show awards")
		
		#if DEBUG
		Button {
			dataController.deleteAll()
			dataController.createSampleData()
		} label: {
			Label("Add Samples", systemImage: "flame")
		}
		#endif
    }
	
	// MARK: - Functions
	func tryNewTag() {
		if dataController.newTag() == false {
			showingStore = true
		}
	}
}

struct SidebarViewToolbar_Previews: PreviewProvider {
    static var previews: some View {
		SidebarViewToolbar()
    }
}
