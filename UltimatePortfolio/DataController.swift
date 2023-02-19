//
//  DataModel.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/18/23.
//

import CoreData

// This dataController conforms to ObservableObject so
// any swiftUI view can watch this for changes.
class DataController: ObservableObject {
	
	// This is responsible for loading and managing local data using Core Data,
	// but also synchronizing that data with iCloud so that all a user’s devices
	// get to share the same data for our app.
	let container: NSPersistentCloudKitContainer
	
	@Published var selectedFilter: Filter? = Filter.all
	
	// Now that we have some sample data to work with,
	// we can build a pre-made data controller suitable for previewing SwiftUI views.
	static var preview: DataController = {
		let dataController = DataController(inMemory: true)
		dataController.createSampleData()
		return dataController
	}()
	
	// Adding an initializer telling our app to load "Main" data model.
	// Adding an "inMemory" Boolean that allows us to preview data more easily.
	init(inMemory: Bool = false) {
		container = NSPersistentCloudKitContainer(name: "Main")
		
		// When this is set to true, we’ll create our data entirely in memory rather than on disk,
		// which means it will just disappear when the application ends –
		// it’s great for previewing in SwiftUI, but also helpful for writing tests.
		if inMemory {
			container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
		}
		
		// Once we’ve configured our Core Data container, we can load it by calling loadPersistentStores().
		// This will load the actual underlying database on disk, or create it if it doesn’t already exist,
		// but if that fails somehow we don’t really have any choice but to bail out – something is very seriously wrong!
		container.loadPersistentStores { storeDescription, error in
			if let error {
				fatalError("Fatal error loading store: \(error.localizedDescription)")
			}
		}
	}
	
	// createSampleData() method will create a bunch of example issues and tags.
	// This is only useful for testing and previewing.
	func createSampleData() {
		
		// Because we defined entities called Issue and Tag, Xcode will automatically
		// synthesize classes called Issue and Tag for us to use,
		// with properties matching all the attributes we defined.
		let viewContext = container.viewContext
		
		// When you create instances of these classes using our Core Data stack,
		// they can be loaded and saved almost automatically – it’s a massive time saver.
		for i in 1...5 {
			let tag = Tag(context: viewContext)
			tag.id = UUID()
			tag.name = "Tag \(i)"
			
			for j in 1...10 {
				let issue = Issue(context: viewContext)
				issue.title = "Issue \(j)"
				issue.content = "Description goes here"
				issue.creationDate = Date.now
				issue.completed = Bool.random()
				issue.priority = Int16.random(in: 0...2)
				tag.addToIssues(issue)
			}
		}
		// First, that view context is a really important concept in Core Data,
		// because it’s effectively the pool of data that has been loaded from disk.
		// We already created and loaded our persistent store, which is the underlying
		// database data that exists in long-term storage, but this view context holds
		// all sorts of active objects in memory as we work with them, and only writes
		// them back to the persistent store when we ask.
		
		// Second, when we create instances of Issue and Tag we need to tell them which
		// view context they are inside. This allows Core Data to track where they were created,
		// so it knows where to save them to later on.
		
		// Third, I’ve given the tags and issues some sensible example data,
		// so we can get a better idea of how our code is working when they are shown in our UI later on.
		
		// Finally, once all the sample objects are created we call save() on our view context,
		// which tells Core Data to write all those new objects to the persistent storage.
		// That might be in memory, in which case it won’t last long, but it might also be permanent storage,
		// in which case it will last for as long as our app is installed,
		// and will even sync up to iCloud if the user has an active iCloud account.
		try? viewContext.save()
	}
	
	// A way to save changes, so that if some other part of our app has made changes to our data it can write those out to disk.
	// We could just pass this directly on to the view context but,
	// a better idea is to only do that if there are some changes to save otherwise we’ll be making Core Data do unnecessary work.
	func save() {
		if container.viewContext.hasChanges {
			try? container.viewContext.save()
		}
	}
	
	// The second method is to delete one specific issue or tag from our view context.
	// This can be passed directly to the view context’s own delete() method,
	// and in fact we can do it all in just one method because all Core Data classes
	// (including the Issue and Tag classes that Xcode generated for us) inherit from a parent class called NSManagedObject.
	func delete(_ object: NSManagedObject) {
		container.viewContext.delete(object)
		save()
	}
	
	// This method will handle deleting all our data, and will be called alongside createSampleData(),
	// so that we can zap the contents of our database instantly. Again, this is only for testing purposes,
	// but it’s really helpful to have this kind of test structure in place so you don’t need to
	// constantly add and delete data by hand while you’re coding.
	
	// I’ve marked the method as being private because we’re going to use it in only one place:
	// our test method to delete all the issues and tags we have stored.
	private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
		let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
		batchDeleteRequest.resultType = .resultTypeObjectIDs
		
		if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
			let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
			NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
		}
		// We’re specifically asking the batch delete request to send back all the object IDs that got deleted.
		
		// That array of object IDs goes into a dictionary with the key NSDeletedObjectsKey, with a default empty array if it can’t be read.
		
		// That dictionary goes into the mergeChanges() method,
		// which is what updates our view context with the changes we just made to the persistent store.
	}
	
	func deleteAll() {
		let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
		delete(request1)
		
		let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
		delete(request2)
		
		save()
	}
}
