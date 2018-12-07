//
//  DXImageResizerFrameView+Getter.swift
//  DXImageResizerView
//
//  Created by fashion on 2018/11/29.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

extension DXImageResizerFrameView {

    // MARK: getter
    public func maxResizeX() -> CGFloat {
        printLog("")
        return maxResizeFrame.origin.x
    }
    public func maxResizeY() -> CGFloat {
        printLog("")
        return maxResizeFrame.origin.y
    }
    public func maxResizeW() -> CGFloat {
        return maxResizeFrame.size.width
    }
    public func maxResizeH() -> CGFloat {
        return maxResizeFrame.size.height
    }
    
    
    public func imageResizerSize() -> CGSize {
        printLog("")
        return CGSize.init(width: imageResizerFrame.size.width, height: imageResizerFrame.size.height)
    }
    public func imageViewSize() -> CGSize {
        printLog("")
        if rotationDirection == .verticalUp || rotationDirection == .verticalDown {
            return CGSize.init(width: imageResizerFrame.size.width, height: imageResizerFrame.size.height)
        }else{
            return CGSize.init(width: imageResizerFrame.size.height, height: imageResizerFrame.size.width)
        }
    }

    
}
