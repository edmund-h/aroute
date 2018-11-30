//
//  UIView+exte nsions.swift
//  ARoute
//
//  Created by Edmund Holderbaum on 11/29/18.
//  Copyright © 2018 Dawn Trigger Enterprises. All rights reserved.
//

import UIKit



extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        
        for subview in subviews {
            recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
        }
        
        return recursiveSubviews
    }
}
