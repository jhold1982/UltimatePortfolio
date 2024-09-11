//
//  PortfolioWidget.swift
//  PortfolioWidget
//
//  Created by Justin Hold on 9/5/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
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

struct PortfolioWidgetEntryView: View {
    var entry: Provider.Entry

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

struct PortfolioWidget: Widget {
    let kind: String = "PortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PortfolioWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PortfolioWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    PortfolioWidget()
} timeline: {
	SimpleEntry(date: .now, issues: [.example])
    SimpleEntry(date: .now, issues: [.example])
}
