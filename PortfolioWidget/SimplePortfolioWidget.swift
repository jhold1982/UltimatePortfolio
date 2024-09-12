//
//  SimplePortfolioWidget.swift
//  PortfolioWidget
//
//  Created by Justin Hold on 9/5/24.
//

import WidgetKit
import SwiftUI

struct SimpleProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(date: Date.now, issues: [.example])
    }

	func getSnapshot(
		in context: Context,
		completion: @escaping (SimpleEntry) -> Void
	) {
		let entry = SimpleEntry(date: Date.now, issues: loadIssues())
        completion(entry)
    }

	func getTimeline(
		in context: Context,
		completion: @escaping (Timeline<Entry>) -> Void
	) {
		
		let entry = SimpleEntry(date: Date.now, issues: loadIssues())
		
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
	
	func loadIssues() -> [Issue] {
		let dataController = DataController()
		let request = dataController.fetchRequestForTopIssues(count: 1)
		return dataController.results(for: request)
	}
}

struct SimpleEntry: TimelineEntry {
    let date: Date
	let issues: [Issue]
}

struct SimplePortfolioWidgetEntryView: View {
    var entry: SimpleProvider.Entry

    var body: some View {
        VStack {
            Text("Up Next...")
				.font(.title)
			if let issue = entry.issues.first {
				Text(issue.issueTitle)
			} else {
				Text("Nothing to see here.")
			}
        }
    }
}

struct SimplePortfolioWidget: Widget {
    let kind: String = "SimplePortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleProvider()) { entry in
            if #available(iOS 17.0, *) {
				SimplePortfolioWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
				SimplePortfolioWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Up Next...")
        .description("Your top priority issue.")
		.supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
	SimplePortfolioWidget()
} timeline: {
	SimpleEntry(date: .now, issues: [.example])
    SimpleEntry(date: .now, issues: [.example])
}
