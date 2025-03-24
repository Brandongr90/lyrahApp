//
//  SwiftUI+Font.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 12/03/25.
//

import SwiftUI

extension Font {
    static func montserrat(fontStyle: Font.TextStyle = .body, fontWeight: Weight = .regular) -> Font {
        return Font.custom(CustomFont(weight: fontWeight).rawValue, size: fontStyle.size)
    }
}

extension Font.TextStyle {
    var size: CGFloat {
        switch self {
        case .largeTitle: return 34
        case .title: return 30
        case .title2: return 22
        case .title3: return 20
        case .headline: return 18
        case .body: return 16
        case .callout: return 15
        case .subheadline: return 14
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        @unknown default: return 8
        }
    }
}

enum CustomFont: String {
    case light = "Montserrat-ExtraLight"
    case thin = "Montserrat-Thin"
    case regular = "Montserrat-Regular"
    case medium = "Montserrat-Medium"
    case semibold = "Montserrat-SemiBold"
    case bold = "Montserrat-Bold"
    case heavy = "Montserrat-ExtraBold"
    case black = "Montserrat-Black"
    
    init(weight: Font.Weight) {
        switch weight {
        case .light:
            self = .light
        case .thin:
            self = .thin
        case .regular:
            self = .regular
        case .medium:
            self = .medium
        case .semibold:
            self = .semibold
        case .bold:
            self = .bold
        case .heavy:
            self = .heavy
        case .black:
            self = .black
        default:
            self = .regular
        }
    }
}
