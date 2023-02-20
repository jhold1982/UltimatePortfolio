//
//  Tag-CoreDataHelpers.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/19/23.
//

import Foundation

extension Tag {
	
	var tagID: UUID {
		id ?? UUID()
	}
	
	var tagName: String {
		name ?? ""
	}
	// This extension doesn't require getters or setters because tags are handled much more simply
	
	static var example: Tag {
		
		let controller = DataController(inMemory: true)
		let viewContext = controller.container.viewContext
		
		let tag = Tag(context: viewContext)
		tag.id = UUID()
		tag.name = "Example tag"
		return tag
	}
}
