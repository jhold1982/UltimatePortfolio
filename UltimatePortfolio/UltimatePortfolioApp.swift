//
//  UltimatePortfolioApp.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/15/23.
//

import SwiftUI
import CoreSpotlight

@main
struct UltimatePortfolioApp: App {
	// Our whole app needs access to a DataController instance,
	// so we want to create one when our app launches,
	// and put it into the SwiftUI environment so it can be read out later on as needed.
	@StateObject var dataController = DataController()
	// That uses @State because our app will create and own the data controller,
	// ensuring it stays alive for the duration of our app’s runtime,
	// but we don’t want to observe the object for changes.
	@Environment(\.scenePhase) var scenePhase
	
	#if os(iOS)
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	#endif
	
    var body: some Scene {
        WindowGroup {
			NavigationSplitView {
				SidebarView(dataController: dataController)
			} content: {
				ContentView(dataController: dataController)
			} detail: {
				DetailView()
			}
			// We need to send our data controller’s view context into the SwiftUI environment using a special key.
			// This is because every time SwiftUI wants to query Core Data it needs to know where to look for all the data,
			// so this effectively connects Core Data to SwiftUI.
			.environment(\.managedObjectContext, dataController.container.viewContext)
			.environmentObject(dataController)
			.onChange(of: scenePhase) { phase in
				if phase != .active {
					dataController.save()
				}
			}
			.onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        }
    }
	// MARK: - Functions
	/// Method for loading a tapped spotlight item
	/// - Parameter userActivity: The action of having tapped the selected item from spotlight
	func loadSpotlightItem(_ userActivity: NSUserActivity) {
		if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
			dataController.selectedIssue = dataController.issue(with: uniqueIdentifier)
			dataController.selectedFilter = .all
			
		}
	}
}
