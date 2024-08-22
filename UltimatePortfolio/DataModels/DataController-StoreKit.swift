//
//  DataController-StoreKit.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 7/17/24.
//

import Foundation
import StoreKit

extension DataController {
	/// The product id for premium unlock
	static let unlockPremiumProductID = "com.lefthandedapps.UltimatePortfolio.premiumUnlock"
	
	/// Loads and saves whether premium unlock has been purchased
	var fullVersionUnlocked: Bool {
		get {
			defaults.bool(forKey: "fullVersionUnlocked")
		}
		
		set {
			defaults.set(newValue, forKey: "fullVersionUnlocked")
		}
	}
	
	@MainActor
	func finalize(_ transaction: Transaction) async {
		if transaction.productID == Self.unlockPremiumProductID {
			objectWillChange.send()
			fullVersionUnlocked = transaction.revocationDate == nil
			await transaction.finish()
		}
	}
	
	
	@MainActor
	/// Method to show progressView before product purchase button appears
	func loadProducts() async throws {
		guard products.isEmpty else { return }
		
		try await Task.sleep(for: .seconds(1.7))
		products = try await Product.products(for: [Self.unlockPremiumProductID])
	}
	
	/*
	 1. **Checking for Previous Purchases**:
		- The function first checks for any previous purchases using a `for await` loop that iterates over `Transaction.currentEntitlements`.
		- For each `entitlement`, it checks if it is a verified transaction using `if case let .verified(transaction) = entitlement`.
		- If a transaction is verified, it calls the `finalize(transaction)` function to handle the transaction.

	 2. **Watching for Future Transactions**:
		- After checking previous purchases, the function enters another `for await` loop to watch for future transactions using `Transaction.updates`.
		- For each `update`, it attempts to extract the transaction from the update using `try? update.payloadValue`.
		- If it successfully retrieves a transaction, it calls the `finalize(transaction)` function to handle the transaction.

	 ### Key Points:
	 - **Asynchronous Function**: The function is asynchronous (`async`), allowing it to perform tasks without blocking the main thread.
	 - **Transaction Entitlements**: `Transaction.currentEntitlements` provides a stream of current transaction entitlements, and the function processes verified ones.
	 - **Transaction Updates**: `Transaction.updates` provides a stream of updates for future transactions, which the function processes if they are successfully retrieved.
	 - **Finalizing Transactions**: The `finalize(transaction)` function is called to handle both previous and future transactions.

	 Overall, this code ensures that both past and future transactions are monitored and appropriately finalized by calling the `finalize(transaction)` function.
	 */
	
	func monitorTransactions() async {
		// check for previous purchases
		for await entitlement in Transaction.currentEntitlements {
			if case let .verified(transaction) = entitlement {
				await finalize(transaction)
			}
		}
		// watch for future transactions
		for await update in Transaction.updates {
			if let transaction = try? update.payloadValue {
				await finalize(transaction)
			}
		}
	}
	
	func purchase(_ product: Product) async throws {
		let result = try await product.purchase()
		
		if case let .success(validation) = result {
			try await finalize(validation.payloadValue)
		}
	}
}
