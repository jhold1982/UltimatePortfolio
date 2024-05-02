//
//  AssetTests.swift
//  UltimatePortfolioTests
//
//  Created by Justin Hold on 6/26/23.
//

import XCTest
@testable import UltimatePortfolio

final class AssetTests: XCTestCase {
	func testColorsExist() {
		let allColors = [
			"HWS Dark Blue", "HWS Dark Gray", "HWS Gold", "HWS Gray", "HWS Green", "HWS Light Blue",
			"HWS Midnight", "HWS Orange", "HWS Pink", "HWS Purple", "HWS Red", "HWS Teal"
		]
		for color in allColors {
			XCTAssertNotNil(
				UIColor(named: color),
				"Failed to load color '\(color)' from asset catalog."
			)
		}
	}
	func testAwardsLoadCorrectly() {
		XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON.")
	}
}
