//
//  InlineNavigationBar.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 9/18/24.
//

import SwiftUI

extension View {
	func inlineNavigationBar() -> some View {
		#if os(macOS)
		self
		#else
		self.navigationBarTitleDisplayMode(.inline)
		#endif
	}
}
