//
//  ThemeManager.swift
//  Darkmode
//
//  Created by iSHIKA on 31/08/23.
//

import Foundation
import UIKit

extension UIColor {
    
    ///  Updates colors while switching the themes inside the App.
    /// - Parameters:
    ///   - light: Color for Light Theme
    ///   - dark:  color for Dark mode
    /// - Returns: dynamic color based on current Theme
    static func themeColor(_ light: UIColor, _ dark: UIColor) -> UIColor {
        return UIColor(dynamicProvider: { return $0.userInterfaceStyle == .dark ? dark : light})
    }
}

typealias AppColors = UIColor
// App colors
extension AppColors {
    // The background for ViewController
    static let appBackground: UIColor = UIColor.themeColor(UIColor(hex: "#F5F5FA"), UIColor.black)
    // backgroundColor for containers
    static let containerBg: UIColor = UIColor.themeColor(UIColor.white, UIColor.darkGray)
    // default labels
    static let labelDefault: UIColor = UIColor.themeColor(UIColor.black, UIColor.white)
    // highlited labels
    static let labelPrimary: UIColor = UIColor.themeColor(UIColor.red, UIColor.orange)
    static let labelWhite: UIColor = UIColor.white
    static let successBg: UIColor = UIColor.themeColor(UIColor.green, UIColor(hex: "#003b00"))
  }

// these are the token names updated by script in stroyboards
enum ColorToken: String {
    case appBackground
    case containerBg  // conatiner colors
    case labelDefault    // label color
    case labelPrimary
    case labelWhite
    case successBg
    /*
     ..... can add more containers and more label colors
    */

    var color: UIColor {
        switch self {
        case .appBackground: return UIColor.appBackground
        case .containerBg: return UIColor.containerBg
        case .labelDefault: return UIColor.labelDefault
        case .labelPrimary: return UIColor.labelPrimary
        case .labelWhite: return UIColor.labelWhite
        case .successBg: return UIColor.successBg
        }
    }
}


extension UIColor {
    convenience init(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int = UInt64()
            Scanner(string: hex).scanHexInt64(&int)
            let a, r, g, b: UInt64
            switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 0, 0, 0)
            }
            self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        }
}
