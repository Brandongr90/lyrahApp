//
//  LyrahLogo.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 24/03/25.
//

import SwiftUI

struct LyrahLogo: View {
    var size: CGFloat = 150
    var useWhite: Bool = false
    
    var body: some View {
        Image(useWhite ? "LogoWhite" : "LogoPrimary")
            .resizable()
            .scaledToFit()
            .frame(width: size)
    }
}
