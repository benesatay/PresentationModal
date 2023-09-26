//
//  Helper.swift
//  
//
//  Created by Bahadır Enes Atay on 18.09.2023.
//

import UIKit

class Helper {
    static let shared = Helper()
    
    private init() {}
    
    let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first

    let screenHeight = UIScreen.main.bounds.height

    var constantOfDismissableHeight: CGFloat {
        return screenHeight/6
    }
    
    var constantOfDragVelocity: CGFloat {
        return 1100
    }
    
    var safeAreaInsets: UIEdgeInsets {
        return window?.safeAreaInsets ?? .zero
    }
    
    var statusBarFrame: CGRect {
        return window?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
    }
    
    func calculatePannedDistance(_ originY: CGFloat, _ visibleDimmedHeight: CGFloat) -> CGFloat {
        return screenHeight - (originY + visibleDimmedHeight)
    }
    
    func isContentHeightOverScreen(_ contentHeight: CGFloat) -> Bool {
        let totalSafeAreaInset = safeAreaInsets.top + safeAreaInsets.bottom
        let safeHeight = screenHeight - totalSafeAreaInset
        return contentHeight >= safeHeight
    }
    
    func calculateVisibleDimmedViewHeight(_ mainViewHeight: CGFloat, _ contentHeight: CGFloat) -> CGFloat {
        return mainViewHeight - contentHeight
    }
}
