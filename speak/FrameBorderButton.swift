//
//  FrameBorderButton.swift
//  speak
//
//  Created by kiri on 2015/05/21.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import UIKit

class FrameBorderButton: UIButton {
    var borderColor : UIColor = UIColor.blackColor()
    override func awakeFromNib() {
        super.awakeFromNib()
        if !borderColor.isEqual(nil) {
            self.layer.borderColor = borderColor.CGColor
        }
    }
}

