//
//  ListCardView.swift
//  SwiftUI-Cards
//
//  Created by Stadelman, Stan on 11/18/19.
//  Copyright © 2019 sap. All rights reserved.
//

import SwiftUI

struct ListItemView: View {

    let icon: Icon?
    let title: String?
    let description: String?
    let actions: [Action] = []
    let highlight: Highlight?
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            SafeView(highlight)
            HStack(alignment: .center, spacing: 12) {
                AsyncImageView(url: icon?.src)
                VStack(alignment: .leading, spacing: 3) {
                    SafeText(title)
                    SafeText(description).lineLimit(1).opacity(0.6)
                }
            }
            .padding(EdgeInsets(top: 10.5, leading: 0, bottom: 10.5, trailing: 0))
        }
    }
}
