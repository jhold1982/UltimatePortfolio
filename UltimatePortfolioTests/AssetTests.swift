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
			"Dark Blue",
			"Dark Gray",
			"Gold",
			"Gray",
			"Green",
			"Light Blue",
			"Midnight",
			"Orange",
			"Pink",
			"Purple",
			"Red",
			"Teal"
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
