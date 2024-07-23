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
}
