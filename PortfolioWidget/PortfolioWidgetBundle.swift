//
//  PortfolioWidgetBundle.swift
//  PortfolioWidget
//
//  Created by Justin Hold on 9/5/24.
//

import WidgetKit
import SwiftUI

@main
struct PortfolioWidgetBundle: WidgetBundle {
    var body: some Widget {
		SimplePortfolioWidget()
		ComplexPortfolioWidget()
    }
}
