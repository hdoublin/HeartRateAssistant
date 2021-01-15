//
//  DotCALayer.swift
//  HeartRate
//
//  Created by mymac on 2021/1/8.
//  Copyright © 2021 Imran Rapiq. All rights reserved.
//

import Foundation
import UIKit

/**
 * DotCALayer
 */
class DotCALayer: CALayer {

    var innerRadius: CGFloat = 8
    var dotInnerColor = UIColor.black

    override init() {
        super.init()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSublayers() {
        super.layoutSublayers()
        let inset = self.bounds.size.width - innerRadius
        let innerDotLayer = CALayer()
        innerDotLayer.frame = self.bounds.insetBy(dx: inset/2, dy: inset/2)
        innerDotLayer.backgroundColor = dotInnerColor.cgColor
        innerDotLayer.cornerRadius = innerRadius / 2
        self.addSublayer(innerDotLayer)
    }

}
