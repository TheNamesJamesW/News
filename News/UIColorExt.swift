//
//  UIColorExt.swift
//  News
//
//  Created by James Wilkinson on 22/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

extension UIColor {
    static var newsyGreen: UIColor {
        return #colorLiteral(red: 0.2078431373, green: 0.8117647059, blue: 0.7098039216, alpha: 1)
    }
    
    func fade(to other: UIColor, distance: CGFloat) -> UIColor {
        precondition((0...1).contains(distance), "Cannot fade beyond 0...1")
        var myRed: CGFloat = 0
        var myGreen: CGFloat = 0
        var myBlue: CGFloat = 0
        guard self.getRed(&myRed, green: &myGreen, blue: &myBlue, alpha: nil) else { return .clear }
        
        var otherRed: CGFloat = 0
        var otherGreen: CGFloat = 0
        var otherBlue: CGFloat = 0
        guard other.getRed(&otherRed, green: &otherGreen, blue: &otherBlue, alpha: nil) else { return .clear }
        
        let r = (1-distance) * myRed + distance*otherRed
        let g = (1-distance) * myGreen + distance*otherGreen
        let b = (1-distance) * myBlue + distance*otherBlue
        
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
