//
//  IssueView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 2/24/23.
//

import SwiftUI

struct IssueView: View {
	
	// MARK: - Properties
	@ObservedObject var issue: Issue
	@EnvironmentObject var dataController: DataController
	@Environment(\.openURL) var openURL
	@State private var showingNotificationsError: Bool = false
	
	// MARK: - View Body
    var body: some View {
		Form {
			Section {
				VStack(alignment: .leading) {
					TextField(
						"Title",
						text: $issue.issueTitle,
						prompt: Text("Enter the issue title here")
					)
						.font(.title)
					Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
						.foregroundStyle(.secondary)
					Text("**Status:** \(issue.issueStatus)")
						.foregroundStyle(.secondary)
				}
				Picker("Priority", selection: $issue.priority) {
					Text("Low").tag(Int16(0))
					Text("Medium").tag(Int16(1))
					Text("High").tag(Int16(2))
				}
				.pickerStyle(.menu)
				
				TagsMenuView(issue: issue)
			}
			
			Section {
				VStack(alignment: .leading) {
					Text("Basic Information")
						.font(.title2)
						.foregroundStyle(.secondary)
					TextField(
						"Description",
						text: $issue.issueContent,
						prompt: Text("Enter the issue description here"),
						axis: .vertical
					)
				}
			}
			
			Section("Reminders") {
				Toggle("Show reminders", isOn: $issue.reminderEnabled.animation())
				
				if issue.reminderEnabled {
					DatePicker(
						"Reminder time",
						selection: $issue.issueReminderTime,
						displayedComponents: .hourAndMinute
					)
				}
			}
		}
		// MARK: - View Modifiers
		.disabled(issue.isDeleted)
		.onReceive(issue.objectWillChange) { _ in
			dataController.queueSave()
		}
		.onSubmit(dataController.save)
		.toolbar {
			IssueViewToolbar(issue: issue)
		}
		.alert("Oops!", isPresented: $showingNotificationsError) {
			Button("Check Settings", action: showAppSettings)
			Button("Cancel", role: .cancel) { }
		} message: {
			Text("There was a problem setting your notification. Please check you have notifications enabled.")
		}
		.onChange(of: issue.reminderEnabled) { _ in
			updateReminder()
		}
		.onChange(of: issue.reminderTime) { _ in
			updateReminder()
		}
    }
	
	// MARK: - Functions
	func showAppSettings() {
		guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else {
			return
		}
		openURL(settingsURL)
	}
	
	func updateReminder() {
		dataController.removeReminders(for: issue)
		
		Task { @MainActor in
			if issue.reminderEnabled {
				let success = await dataController.addReminders(for: issue)
				
				if success == false {
					issue.reminderEnabled = false
					showingNotificationsError = false
				}
			}
		}
	}
}

//struct IssueView_Previews: PreviewProvider {
//    static var previews: some View {
//		IssueView(issue: .example)
//    }
//}
