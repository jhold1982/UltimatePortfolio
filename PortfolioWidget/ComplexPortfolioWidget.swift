//
//  ComplexPortfolioWidget.swift
//  PortfolioWidget
//
//  Created by Justin Hold on 9/5/24.
//

import WidgetKit
import SwiftUI

struct ComplexProvider: TimelineProvider {
	func placeholder(in context: Context) -> ComplexEntry {
		ComplexEntry(date: Date.now, issues: [.example])
	}

	func getSnapshot(
		in context: Context,
		completion: @escaping (ComplexEntry) -> Void
	) {
		let entry = ComplexEntry(date: Date.now, issues: loadIssues())
		completion(entry)
	}

	func getTimeline(
		in context: Context,
		completion: @escaping (Timeline<Entry>) -> Void
	) {
		
		let entry = ComplexEntry(date: Date.now, issues: loadIssues())
		
		let timeline = Timeline(entries: [entry], policy: .never)
		completion(timeline)
	}
	
	func loadIssues() -> [Issue] {
		let dataController = DataController()
		let request = dataController.fetchRequestForTopIssues(count: 1)
		return dataController.results(for: request)
	}
}

struct ComplexEntry: TimelineEntry {
	let date: Date
	let issues: [Issue]
}

struct ComplexPortfolioWidgetEntryView: View {
	
	// MARK: - Environemnt Variables
	@Environment(\.widgetFamily) var widgetFamily
	@Environment(\.dynamicTypeSize) var dynamicTypeSize
	
	// MARK: - Properties
	var entry: ComplexProvider.Entry
	
	var issues: ArraySlice<Issue> {
		let issueCount: Int
		
		switch widgetFamily {
		case .systemSmall:
			issueCount = 1
			
		case .systemLarge, .systemExtraLarge:
			if dynamicTypeSize < .xLarge {
				issueCount = 6
			} else {
				issueCount = 5
			}
			
		default:
			if dynamicTypeSize < .xLarge {
				issueCount = 3
			} else {
				issueCount = 2
			}
		}
		
		return entry.issues.prefix(issueCount)
	}

	// MARK: - Widget View Body
	var body: some View {
		VStack(spacing: 10) {
			ForEach(entry.issues) { issue in
				Link(destination: issue.objectID.uriRepresentation()) {
					VStack(alignment: .leading) {
						Text(issue.issueTitle)
							.font(.headline)
							.layoutPriority(1)
						
						if issue.issueTags.isEmpty == false {
							Text(issue.issueTagsList)
								.foregroundStyle(.secondary)
						}
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
		}
	}
}

struct ComplexPortfolioWidget: Widget {
	let kind: String = "ComplexPortfolioWidget"

	var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: ComplexProvider()) { entry in
			if #available(iOS 17.0, *) {
				ComplexPortfolioWidgetEntryView(entry: entry)
					.containerBackground(.fill.tertiary, for: .widget)
			} else {
				ComplexPortfolioWidgetEntryView(entry: entry)
					.padding()
					.background()
			}
		}
		.configurationDisplayName("Up Next...")
		.description("Your most important issues.")
		.supportedFamilies(
			[
				.systemSmall,
				.systemMedium,
				.systemLarge,
				.systemExtraLarge
			]
		)
	}
}

#Preview(as: .systemSmall) {
	ComplexPortfolioWidget()
} timeline: {
	ComplexEntry(date: .now, issues: [.example])
	ComplexEntry(date: .now, issues: [.example])
}
