//
//  DataModel.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/18/23.
//

import CoreData

class DataController: ObservableObject {
	
	let container: NSPersistentCloudKitContainer
	
	@Published var selectedFilter: Filter? = Filter.all
	@Published var selectedIssue: Issue?
	
	private var saveTask: Task<Void, Error>?
	
	static var preview: DataController = {
		let dataController = DataController(inMemory: true)
		dataController.createSampleData()
		return dataController
	}()
	
	init(inMemory: Bool = false) {
		container = NSPersistentCloudKitContainer(name: "Main")
		if inMemory {
			container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
		}
		container.viewContext.automaticallyMergesChangesFromParent = true
		container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
		container.persistentStoreDescriptions.first?.setOption(
			true as NSNumber,
			forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
		)
		NotificationCenter.default.addObserver(
			forName: .NSPersistentStoreRemoteChange,
			object: container.persistentStoreCoordinator,
			queue: .main,
			using: remoteStoreChanged
		)
		container.loadPersistentStores { storeDescription, error in
			if let error {
				fatalError("Fatal error loading store: \(error.localizedDescription)")
			}
		}
	}
	
	func remoteStoreChanged(_ notification: Notification) {
		objectWillChange.send()
	}
	
	func createSampleData() {
		let viewContext = container.viewContext
		
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
		try? viewContext.save()
	}
	
	func save() {
		if container.viewContext.hasChanges {
			try? container.viewContext.save()
		}
	}
	
	func queueSave() {
		saveTask?.cancel()
		saveTask = Task { @MainActor in
			try await Task.sleep(for: .seconds(3))
			save()
		}
	}
	
	func delete(_ object: NSManagedObject) {
		objectWillChange.send()
		container.viewContext.delete(object)
		save()
	}
	
	func deleteAll() {
		let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
		delete(request1)
		let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
		delete(request2)
		save()
	}
	
	func missingTags(from issue: Issue) -> [Tag] {
		let request = Tag.fetchRequest()
		let allTags = (try? container.viewContext.fetch(request)) ?? []
		
		let allTagsSet = Set(allTags)
		let difference = allTagsSet.symmetricDifference(issue.issueTags)
		return difference.sorted()
	}
	
	private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
		let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
		batchDeleteRequest.resultType = .resultTypeObjectIDs
		
		if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
			let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
			NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
		}
	}
	
	
}
