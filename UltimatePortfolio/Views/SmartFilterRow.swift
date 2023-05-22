//
//  SmartFilterRow.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 5/22/23.
//

import SwiftUI

struct SmartFilterRow: View {
	var filter: Filter
    var body: some View {
		NavigationLink(value: filter) {
			Label(LocalizedStringKey(filter.name), systemImage: filter.icon)
		}
    }
}

struct SmartFilterRow_Previews: PreviewProvider {
    static var previews: some View {
		SmartFilterRow(filter: .all)
    }
}
