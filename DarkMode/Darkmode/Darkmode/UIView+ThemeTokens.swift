//
//  UIView+ThemeTokens.swift
//  Darkmode
//
//  Created by iSHIKA on 31/08/23.
//

import Foundation
import UIKit

/*
 Color tokens used in storyboards mapped with theme colors
 */
@IBDesignable extension UIView {
    @IBInspectable var tkBgColor: String {
        get {
           return ""
        } set {
            guard let bgColor = ColorToken(rawValue: newValue)?.color else {
                return
            }
            self.backgroundColor = bgColor
        }
    }
}

@IBDesignable extension UILabel {
    @IBInspectable var tkTextColor: String {
        get {
           return ""
        } set {
            guard let txtColor = ColorToken(rawValue: newValue)?.color else {
                return
            }
            self.textColor = txtColor
        }
    }
}

@IBDesignable extension UIButton {
    @IBInspectable var tkTextColor: String {
        get {
           return ""
        } set {
            guard let color = ColorToken(rawValue: newValue)?.color else {
                return
            }
            self.titleLabel?.textColor = color
        }
    }
}

@IBDesignable extension UISwitch {
    @IBInspectable var tkOnTintColor: String {
        get {
           return ""
        } set {
            guard let color = ColorToken(rawValue: newValue)?.color else {
                return
            }
            self.onTintColor = color
        }
    }
}

@IBDesignable extension UIImageView {
    @IBInspectable var tkImageColor: String {
        get {
           return ""
        } set {
            guard let color = ColorToken(rawValue: newValue)?.color else {
                return
            }
            self.image = self.image?.withTintColor(color)
        }
    }
}

