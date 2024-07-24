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
