//
//  DataModel.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/18/23.
//

import CoreData

enum SortType: String {
	case dateCreated = "creationDate"
	case dateModified = "modificationDate"
}

enum Status {
	case all, open, closed
}

/// An environment singleton responsible for managing our Core Data stack, including handling saving,
/// counting fetch requests, tracking orders, and dealing with sample data.
class DataController: ObservableObject {
	/// The lone CloudKit container used to store all our data.
	let container: NSPersistentCloudKitContainer

	@Published var selectedFilter: Filter? = Filter.all
	@Published var selectedIssue: Issue?

	@Published var filterText = ""
	@Published var filterTokens = [Tag]()

	@Published var filterEnabled = false
	@Published var filterPriority = -1
	@Published var filterStatus = Status.all
	@Published var sortType = SortType.dateCreated
	@Published var sortNewestFirst = true

	private var saveTask: Task<Void, Error>?

	static var preview: DataController = {
		let dataController = DataController(inMemory: true)
		dataController.createSampleData()
		return dataController
	}()

	var suggestedFilterTokens: [Tag] {
		guard filterText.starts(with: "#") else {
			return []
		}

		let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
		let request = Tag.fetchRequest()

		if trimmedFilterText.isEmpty == false {
			request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
		}

		return (try? container.viewContext.fetch(request).sorted()) ?? []
	}

	static let model: NSManagedObjectModel = {
		guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
			fatalError("Failed to locate model file.")
		}

		guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
			fatalError("Failed to load model file.")
		}

		return managedObjectModel
	}()

	/// Initializes a data controller, either in memory (for testing use such as previewing),
	/// or on permanent storage (for use in regular app runs.)
	///
	/// Defaults to permanent storage.
	/// - Parameter inMemory: Whether to store this data in temporary memory or not.
	init(inMemory: Bool = false) {
		container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

		// For testing and previewing purposes, we create a
		// temporary, in-memory database by writing to /dev/null
		// so our data is destroyed after the app finishes running.
		if inMemory {
			container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
		}

		container.viewContext.automaticallyMergesChangesFromParent = true
		container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

		// Make sure that we watch iCloud for all changes to make
		// absolutely sure we keep our local UI in sync when a
		// remote change happens.
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

		container.loadPersistentStores { _, error in
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

		for tagCounter in 1...5 {
			let tag = Tag(context: viewContext)
			tag.id = UUID()
			tag.name = "Tag \(tagCounter)"

			for issueCounter in 1...10 {
				let issue = Issue(context: viewContext)
				issue.title = "Issue \(tagCounter)-\(issueCounter)"
				issue.content = "Description goes here"
				issue.creationDate = .now
				issue.completed = Bool.random()
				issue.priority = Int16.random(in: 0...2)
				tag.addToIssues(issue)
			}
		}

		try? viewContext.save()
	}

	/// Saves our Core Data context iff there are changes. This silently ignores
	/// any errors caused by saving, but this should be fine because
	/// all our attributes are optional.
	func save() {
		saveTask?.cancel()

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

	private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
		let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
		batchDeleteRequest.resultType = .resultTypeObjectIDs

		// ⚠️ When performing a batch delete we need to make sure we read the result back
		// then merge all the changes from that result back into our live view context
		// so that the two stay in sync.
		if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
			let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
			NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
		}
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

	/// Runs a fetch request with various predicates that filter the user's issues based on
	/// tag, title, and content text, search tokens, priority, and completion status.
	/// - Returns: An array of all matching issues.
	func issuesForSelectedFilter() -> [Issue] {
		let filter = selectedFilter ?? .all
		var predicates = [NSPredicate]()

		if let tag = filter.tag {
			let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
			predicates.append(tagPredicate)
		} else {
			let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
			predicates.append(datePredicate)
		}

		let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)

		if trimmedFilterText.isEmpty == false {
			let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
			let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)

			let combinedPredicate = NSCompoundPredicate(
				orPredicateWithSubpredicates: [titlePredicate, contentPredicate]
			)

			predicates.append(combinedPredicate)
		}

		if filterTokens.isEmpty == false {
			for filterToken in filterTokens {
				let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", filterToken)
				predicates.append(tokenPredicate)
			}
		}

		if filterEnabled {
			if filterPriority >= 0 {
				let priorityFilter = NSPredicate(format: "priority = %d", filterPriority)
				predicates.append(priorityFilter)
			}

			if filterStatus != .all {
				let lookForClosed = filterStatus == .closed
				let statusFilter = NSPredicate(format: "completed = %@", NSNumber(value: lookForClosed))
				predicates.append(statusFilter)
			}
		}

		let request = Issue.fetchRequest()
		request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
		request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]
		let allIssues = (try? container.viewContext.fetch(request)) ?? []
		return allIssues
	}

	func newTag() {
		let tag = Tag(context: container.viewContext)
		tag.id = UUID()
		tag.name = NSLocalizedString("New tag", comment: "Create a new tag")
		save()
	}

	func newIssue() {
		let issue = Issue(context: container.viewContext)
		issue.title = NSLocalizedString("New issue", comment: "Create a new issue")
		issue.creationDate = .now
		issue.priority = 1

		// If we are currently browsing a user-created tag, immediately
		// add this new issue to the tag otherwise it won't appear in
		// the list of issues they see.
		if let tag = selectedFilter?.tag {
			issue.addToTags(tag)
		}

		save()

		selectedIssue = issue
	}

	func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
		(try? container.viewContext.count(for: fetchRequest)) ?? 0
	}

	func hasEarned(award: Award) -> Bool {
		switch award.criterion {
		case "issues":
			// return true if they added a certain number of issues
			let fetchRequest = Issue.fetchRequest()
			let awardCount = count(for: fetchRequest)
			return awardCount >= award.value

		case "closed":
			// return true if they closed a certain number of issues
			let fetchRequest = Issue.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "completed = true")
			let awardCount = count(for: fetchRequest)
			return awardCount >= award.value

		case "tags":
			// return true if they created a certain number of tags
			let fetchRequest = Tag.fetchRequest()
			let awardCount = count(for: fetchRequest)
			return awardCount >= award.value

		default:
			// an unknown award criterion; this should never be allowed
			// fatalError("Unknown award criterion: \(award.criterion)")
			return false
		}
	}
}
