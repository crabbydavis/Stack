//
//  CustomTabBar.swift
//  Stack
//
//  Created by Davis Crabb on 5/21/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import UIKit

class CustomTabBar: UITabBar{

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        guard let window = UIApplication.shared.keyWindow else {
            return super.sizeThatFits(size)
        }
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = window.safeAreaInsets.bottom + 70
        return sizeThatFits
    }
}
