//
//  BaseScrollView.swift
//  
//
//  Created by Bahadır Enes Atay on 12.08.2023.
//

import UIKit

class BaseScrollView: UIScrollView {
    
    enum ScrollDirection {
        case top
        case bottom
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func scrollToBottom() {
        scroll(to: .bottom, contentInset.bottom)
    }

    public func scrollToTop() {
        scroll(to: .top, contentInset.top)
    }
    
    public func scroll(to direction: ScrollDirection, _ distance: CGFloat) {
        var offset = CGPoint()
        switch direction {
        case .top:
            offset = CGPoint(x: 0, y: -distance)
        case .bottom:
            offset = CGPoint(x: 0, y: contentSize.height - bounds.height + distance)
        }
        setContentOffset(offset, animated: true)
    }
}
