//
//  StoreView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 7/24/24.
//

import SwiftUI
import StoreKit

struct StoreView: View {
	
	// MARK: - Enums
	enum LoadState {
		case loading
		case loaded
		case error
	}
	
	// MARK: - Properties
	@EnvironmentObject var dataController: DataController
	@Environment(\.dismiss) var dismiss
	
	@State private var loadState = LoadState.loading
	
	@State private var showingPurchaseError: Bool = false
	
	// MARK: - View Body
    var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				// Header View
				VStack {
					Image(decorative: "unlock")
						.resizable()
						.scaledToFit()
					
					Text("Upgrade now!")
						.font(.title.bold())
						.fontDesign(.rounded)
						.foregroundStyle(.white)
					
					Text("Get the most out of our app")
						.font(.headline)
						.foregroundStyle(.white)
				}
				.frame(maxWidth: .infinity)
				.padding(2)
				.background(.blue.gradient)
				
				ScrollView {
					VStack {
						switch loadState {
						case .loading:
							Text("u got mad rizz")
								.font(.title2.bold())
								.padding(.top, 30)
							
							ProgressView()
								.controlSize(.mini)
						case .loaded:
							ForEach(dataController.products) { product in
								Button {
									purchase(product)
								} label: {
									HStack {
										VStack(alignment: .leading) {
											Text(product.displayName)
												.font(.title2.bold())
											
											Text(product.description)
										}
										Spacer()
										
										Text(product.displayPrice)
											.font(.title)
											.fontDesign(.rounded)
									}
									.padding(.horizontal, 20)
									.padding(.vertical, 10)
									.frame(maxWidth: .infinity)
									.background(.gray.opacity(0.2), in: .rect(cornerRadius: 20))
									.contentShape(.rect)
								}
								.buttonStyle(.plain)
							}
							
						case .error:
							Text("Sorry, there was an error loading our store.")
								.padding(.top, 30)
							// retry code below
							
							Button("Try Again") {
								Task {
									await load()
								}
							}
							.buttonStyle(.borderedProminent)
						}
					}
					.padding(20)
				}
				
				// Footer View
				Button("Restore Purchases", action: restore)
				
				Button("Cancel", role: .destructive) {
					dismiss()
				}
//				.foregroundStyle(.red)
				.padding(.top, 20)
			}
		}
		.alert("In-app purchases are disabled", isPresented: $showingPurchaseError) {
			//
		} message: {
			Text("""
			You can't purchase the premium unlock because in-app purchase are disabled on this device.
			
			Please ask whomever manages your device for assistance.
			""")
		}
		.onChange(of: dataController.fullVersionUnlocked) { _, _ in
			checkForPurchase()
		}
		.task {
			await load()
		}
    }
	
	// MARK: - Functions
	func checkForPurchase() {
		if dataController.fullVersionUnlocked {
			dismiss()
		}
	}
	
	func purchase(_ product: Product) {
		
		guard AppStore.canMakePayments else {
			showingPurchaseError.toggle()
			return
		}
		
		Task { @MainActor in
			try await dataController.purchase(product)
		}
	}
	
	func load() async {
		loadState = .loading
		
		do {
			try await dataController.loadProducts()
			
			if dataController.products.isEmpty {
				loadState = .error
			} else {
				loadState = .loaded
			}
		} catch {
			loadState = .error
		}
	}
	
	func restore() {
		Task {
			try await AppStore.sync()
		}
	}
}
