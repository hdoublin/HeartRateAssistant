//
//  UIViewExtension.swift
//  MyHealthApp
//
//  Created by Imran Rapiq on 24/5/20.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

extension UIView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
  }
}
