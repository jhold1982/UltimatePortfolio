//
//  StoreView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 7/24/24.
//

import SwiftUI
import StoreKit

struct StoreView: View {
	
	// MARK: - Properties
	@EnvironmentObject var dataController: DataController
	@Environment(\.dismiss) var dismiss
	
	@State private var products = [Product]()
	
	// MARK: - View Body
    var body: some View {
		NavigationStack {
			if let product = products.first {
				VStack(alignment: .leading) {
					Text(product.displayName)
						.font(.title)
					
					Text(product.description)
					
					Button("Buy Now") {
						// handle purchasing
					}
				}
			}
		}
		.onChange(of: dataController.fullVersionUnlocked) { _ in
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
		Task { @MainActor in
			try await dataController.purchase(product)
		}
	}
	
	func load() async {
		do {
			products = try await Product.products(for: [DataController.unlockPremiumProductID])
		} catch {
			print("Failed to load products: \(error.localizedDescription)")
		}
	}
}

//#Preview {
//    StoreView()
//}
