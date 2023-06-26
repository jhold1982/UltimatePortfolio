//
//  UltimatePortfolioTests.swift
//  UltimatePortfolioTests
//
//  Created by Justin Hold on 6/26/23.
//

import XCTest
import CoreData
@testable import UltimatePortfolio

class BaseTestCase: XCTestCase {
	var dataController: DataController!
	var managedObjectContext: NSManagedObjectContext!
	
	override func setUpWithError() throws {
		dataController = DataController(inMemory: true)
		managedObjectContext = dataController.container.viewContext
	}
}
