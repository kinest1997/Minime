//
//  UIColor.swift
//  Cocktail
//
//  Created by 강희성 on 2022/01/01.
//

import Foundation
import UIKit

extension UIColor {
    
    static var mainGray: UIColor {
        get {
            return UIColor(named: "miniButtonGray")!
        }
    }
    
//    static var mainOrange: UIColor {
//        get {
//            return UIColor(named: "shaker")!
//        }
//    }
    
    static var borderGray: UIColor {
        get {
            return UIColor(named: "selectedGray")!
        }
    }
    
//    static var splitLineGray: UIColor {
//        get {
//            return UIColor(named: "splitLineGray")!
//        }
//    }
    
    static var tappedOrange: UIColor {
        get {
            return UIColor(named: "mainOrangeColor")!
        }
    }
}
