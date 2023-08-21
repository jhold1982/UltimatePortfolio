//
//  PerformanceTests.swift
//  UltimatePortfolioTests
//
//  Created by Justin Hold on 8/21/23.
//

import XCTest
@testable import UltimatePortfolio

final class PerformanceTests: BaseTestCase {

	func testAwardCalculationPerformance() {
		for _ in 1...100 {
			dataController.createSampleData()
		}
		
		let awards = Array(repeating: Award.allAwards, count: 25).joined()
		
		measure {
			_ = awards.filter(dataController.hasEarned)
		}
	}
}
