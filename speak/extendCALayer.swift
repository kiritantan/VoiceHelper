//
//  extendCALayer.swift
//  speak
//
//  Created by kiri on 2015/11/30.
//  Copyright © 2015年 kiri. All rights reserved.
//

import UIKit

extension CALayer {
    func setBorderIBColor(color: UIColor) -> Void {
        self.borderColor = color.CGColor
    }
}