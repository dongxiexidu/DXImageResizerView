//
//  DXImageResizerFrameView+Pan.swift
//  DXImageResizerView
//
//  Created by fashion on 2018/11/29.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit


extension DXImageResizerFrameView{
    
    // MARK: UIPanGestureRecognizer
    @objc func panHandle(pan: UIPanGestureRecognizer) {
        printLog("")
        let translation = pan.translation(in: self)
        pan.setTranslation(CGPoint.zero, in: self)
        
        if pan.state == .began {
            panBeganHandle(location: panGR.location(in: self))
        }
        if pan.state == .changed {
            panChangedHandle(translation: translation)
        }
        if pan.state == .ended || pan.state == .cancelled || pan.state == .failed{
            endedImageResizer()
        }
    }
    
    private func panBeganHandle(location: CGPoint) {
        printLog("")
        startImageResizer()
        
        let x : CGFloat = self.imageResizeX
        let y : CGFloat = self.imageResizeY
        let width : CGFloat = self.imageResizeW
        let height : CGFloat = self.imageResizeH
        
        let midX : CGFloat = self.imageResizerFrame.midX
        let midY : CGFloat = self.imageResizerFrame.midY
        let maxX : CGFloat = self.imageResizerFrame.maxX
        let maxY : CGFloat = self.imageResizerFrame.maxY
        
        let scopeWH : CGFloat = _scopeWH
        let halfScopeWH : CGFloat = scopeWH * 0.5
        let leftTopRect = CGRect.init(x: x-halfScopeWH, y: y-halfScopeWH, width: scopeWH, height: scopeWH)
        let leftBotRect = CGRect.init(x: x-halfScopeWH, y: maxY-halfScopeWH, width: scopeWH, height: scopeWH)
        let rightTopRect = CGRect.init(x: maxX-halfScopeWH, y: y-halfScopeWH, width: scopeWH, height: scopeWH)
        let rightBotRect = CGRect.init(x: maxX-halfScopeWH, y: maxY-halfScopeWH, width: scopeWH, height: scopeWH)
        
        let leftMidRect = CGRect.init(x: x-halfScopeWH, y: midY-halfScopeWH, width: scopeWH, height: scopeWH)
        let rightMidRect = CGRect.init(x: maxX-halfScopeWH, y: midY-halfScopeWH, width: scopeWH, height: scopeWH)
        
        let topMidRect = CGRect.init(x: midX-halfScopeWH, y: y-halfScopeWH, width: scopeWH, height: scopeWH)
        let botMidRect = CGRect.init(x: midX-halfScopeWH, y: maxY-halfScopeWH, width: scopeWH, height: scopeWH)
        
        if leftTopRect.contains(location) {
            self.currHorn = .leftTop
            self.diagonal = CGPoint.init(x: x + width, y: y + height)
        } else if leftBotRect.contains(location) {
            self.currHorn = .leftBottom
            self.diagonal = CGPoint.init(x: x + width, y: y)
        } else if rightTopRect.contains(location) {
            self.currHorn = .rightTop
            self.diagonal = CGPoint.init(x: x, y: y + height)
            
        } else if rightBotRect.contains(location) {
            self.currHorn = .rightBottom
            self.diagonal = CGPoint.init(x: x , y: y)
            
        } else if leftMidRect.contains(location) && self.isShowMidDot() {
            self.currHorn = .leftMid
            self.diagonal = CGPoint.init(x: maxX, y: maxY)
            
        } else if rightMidRect.contains(location) && self.isShowMidDot() {
            self.currHorn = .rightMid
            self.diagonal = CGPoint.init(x: x, y: midY)
            
        } else if topMidRect.contains(location) && self.isShowMidDot() {
            self.currHorn = .topMid
            self.diagonal = CGPoint.init(x: midX, y: maxY)
            
        } else if botMidRect.contains(location) && self.isShowMidDot() {
            self.currHorn = .bottomMid
            self.diagonal = CGPoint.init(x: midX, y: y)
        } else {
            self.currHorn = .center
        }
        _startResizeW = width
        _startResizeH = height
    }
    private func panChangedHandle(translation: CGPoint) {
        printLog("")
        var x = imageResizeX
        var y = imageResizeY
        var width = imageResizeW
        var height = imageResizeH
        
        switch self.currHorn {
        case .leftTop:
            if _isArbitrarily {
                x += translation.x
                y += translation.y
                
                if x < self.maxResizeX() {
                    x = self.maxResizeX()
                }
                
                if y < self.maxResizeY() {
                    y = self.maxResizeY()
                }
                
                width = self.diagonal.x - x
                height = self.diagonal.y - y
                
                if width < _minImageWH {
                    width = _minImageWH
                    x = self.diagonal.x - width
                }
                
                if height < _minImageWH {
                    height = _minImageWH
                    y = self.diagonal.y - height
                }
            } else {
                x += translation.x
                width = self.diagonal.x - x
                
                if (translation.x != 0) {
                    let diff = translation.x / self.resizeWHScale
                    y += diff
                    height = self.diagonal.y - y
                }
                
                if x < self.maxResizeX() {
                    x = self.maxResizeX()
                    width = self.diagonal.x - x
                    height = width / self.resizeWHScale
                    y = self.diagonal.y - height
                }
                
                if y < self.maxResizeY() {
                    y = self.maxResizeY()
                    height = self.diagonal.y - y
                    width = height * self.resizeWHScale
                    x = self.diagonal.x - width
                }
                
                if width < _minImageWH || height < _minImageWH {
                    if self.resizeWHScale >= 1 {
                        width = _minImageWH
                        height = width / self.resizeWHScale
                    } else {
                        height = _minImageWH
                        width = height * self.resizeWHScale
                    }
                    x = self.diagonal.x - width
                    y = self.diagonal.y - height
                }
            }
        case .leftBottom:
            if _isArbitrarily {
                x += translation.x
                height = height + translation.y
                
                if x < self.maxResizeX() {
                    x = self.maxResizeX()
                }
                
                let maxResizeMaxY = self.maxResizeFrame.maxY
                if (y + height) > maxResizeMaxY {
                    height = maxResizeMaxY - self.diagonal.y
                }
                
                width = self.diagonal.x - x
                
                if width < _minImageWH {
                    width = _minImageWH
                    x = self.diagonal.x - width
                }
                
                if height < _minImageWH {
                    height = _minImageWH
                }
            } else {
                x += translation.x
                width = self.diagonal.x - x
                
                if translation.x != 0 {
                    height = width / self.resizeWHScale
                }
                
                if (x < self.maxResizeX()) {
                    x = self.maxResizeX()
                    width = self.diagonal.x - x
                    height = width / self.resizeWHScale
                }
                
                let maxResizeMaxY = self.maxResizeFrame.maxY
                if (y + height) > maxResizeMaxY {
                    height = maxResizeMaxY - self.diagonal.y
                    width = height * self.resizeWHScale
                    x = self.diagonal.x - width
                }
                
                if width < _minImageWH || height < _minImageWH {
                    if self.resizeWHScale >= 1 {
                        width = _minImageWH
                        height = width / self.resizeWHScale
                    } else {
                        height = _minImageWH
                        width = height * self.resizeWHScale
                    }
                    x = self.diagonal.x - width
                    y = self.diagonal.y
                }
            }
        case .rightTop:
            if _isArbitrarily {
                y += translation.y
                width = width + translation.x
                
                if y < self.maxResizeY() {
                    y = self.maxResizeY()
                }
                
                let maxResizeMaxX = self.maxResizeFrame.maxX
                if (x + width) > maxResizeMaxX {
                    width = maxResizeMaxX - self.diagonal.x
                }
                
                height = self.diagonal.y - y
                
                if width < _minImageWH {
                    width = _minImageWH
                }
                
                if height < _minImageWH {
                    height = _minImageWH
                    y = self.diagonal.y - height
                }
            } else {
                width = width + translation.x;
                
                if translation.x != 0 {
                    let diff = translation.x / self.resizeWHScale
                    y -= diff
                    height = self.diagonal.y - y
                }
                
                if y < self.maxResizeY() {
                    y = self.maxResizeY()
                    height = self.diagonal.y - y
                    width = height * self.resizeWHScale
                }
                
                let maxResizeMaxX = self.maxResizeFrame.maxX
                if (x + width) > maxResizeMaxX {
                    width = maxResizeMaxX - self.diagonal.x
                    height = width / self.resizeWHScale
                    y = self.diagonal.y - height
                }
                
                if width < _minImageWH || height < _minImageWH {
                    if self.resizeWHScale >= 1 {
                        width = _minImageWH;
                        height = width / self.resizeWHScale
                    } else {
                        height = _minImageWH;
                        width = height * self.resizeWHScale
                    }
                    x = self.diagonal.x
                    y = self.diagonal.y - height
                }
            }
        case .rightBottom:
            if _isArbitrarily {
                width = width + translation.x
                height = height + translation.y
                
                let maxResizeMaxX = self.maxResizeFrame.maxX
                if (x + width) > maxResizeMaxX {
                    width = maxResizeMaxX - self.diagonal.x
                }
                
                let maxResizeMaxY = self.maxResizeFrame.maxY
                if (y + height) > maxResizeMaxY {
                    height = maxResizeMaxY - self.diagonal.y
                }
                
                if width < _minImageWH {
                    width = _minImageWH
                }
                
                if height < _minImageWH {
                    height = _minImageWH
                }
            } else {
                width = width + translation.x
                
                if translation.x != 0 {
                    height = width / self.resizeWHScale
                }
                
                let maxResizeMaxX = self.maxResizeFrame.maxX
                if (x + width) > maxResizeMaxX {
                    width = maxResizeMaxX - self.diagonal.x
                    height = width / self.resizeWHScale
                }
                
                let maxResizeMaxY = self.maxResizeFrame.maxY
                if (y + height) > maxResizeMaxY {
                    height = maxResizeMaxY - self.diagonal.y
                    width = height * self.resizeWHScale
                }
                
                if width < _minImageWH || height < _minImageWH {
                    if self.resizeWHScale >= 1 {
                        width = _minImageWH
                        height = width / self.resizeWHScale
                    } else {
                        height = _minImageWH
                        width = height * self.resizeWHScale
                    }
                    x = self.diagonal.x
                    y = self.diagonal.y
                }
            }
           
        case .leftMid:
            x += translation.x
            
            if x < self.maxResizeX() {
                x = self.maxResizeX()
            }
            
            width = self.diagonal.x - x
            
            if width < _minImageWH {
                width = _minImageWH
                x = self.diagonal.x - width
            }
        case .rightMid:
            width = width + translation.x
            let maxResizeMaxX = self.maxResizeFrame.maxX
            if (x + width) > maxResizeMaxX {
                width = maxResizeMaxX - self.diagonal.x
            }
            
            if width < _minImageWH {
                width = _minImageWH
            }
            
        case .topMid:
            y += translation.y
            
            if y < self.maxResizeY() {
                y = self.maxResizeY()
            }
            
            height = self.diagonal.y - y
            
            if height < _minImageWH {
                height = _minImageWH
                y = self.diagonal.y - height
            }
        case .bottomMid:
            height = height + translation.y
            
            let maxResizeMaxY = self.maxResizeFrame.maxY
            if (y + height) > maxResizeMaxY {
                height = maxResizeMaxY - self.diagonal.y
            }
            
            if (height < _minImageWH) {
                height = _minImageWH;
            }
            
        default:
            break
        }
        
        self.imageResizerFrame = CGRect.init(x: x, y: y, width: width, height: height)
        let zoomFrame : CGRect = convert(self.imageResizerFrame, to: self.imageView)
        var contentOffset = self.scrollView.contentOffset
        
        if zoomFrame.origin.x < 0 {
            contentOffset.x -= zoomFrame.origin.x
        } else if zoomFrame.maxX > _baseImageW {
            contentOffset.x -= zoomFrame.maxX - _baseImageW;
        }
        if zoomFrame.origin.y < 0 {
            contentOffset.y -= zoomFrame.origin.y
        } else if zoomFrame.maxY > _baseImageH {
            contentOffset.y -= zoomFrame.maxY - _baseImageH
        }
        
        self.scrollView.setContentOffset(contentOffset, animated: false)
        var wZoomScale : CGFloat = 0
        var hZoomScale : CGFloat = 0
        if width > _startResizeW {
            wZoomScale = width / _baseImageW
        }
        if height > _startResizeH {
            hZoomScale = height / _baseImageH
        }
        let zoomScale = max(wZoomScale, hZoomScale)
        if zoomScale > self.scrollView.zoomScale {
            self.scrollView.setZoomScale(zoomScale, animated: false)
        }
    }
    
    
    // MARK: - super method
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        printLog("")
        if self.panGR.isEnabled == false {
            return false
        }
        
        let x : CGFloat = self.imageResizeX
        let y : CGFloat = self.imageResizeY
        let midX : CGFloat = self.imageResizerFrame.midX
        let midY : CGFloat = self.imageResizerFrame.midY
        let maxX : CGFloat = self.imageResizerFrame.maxX
        let maxY : CGFloat = self.imageResizerFrame.maxY
        
        let scopeWH : CGFloat = _scopeWH
        let halfScopeWH : CGFloat = scopeWH * 0.5
        let leftTopRect = CGRect.init(x: x-halfScopeWH, y: y-halfScopeWH, width: scopeWH, height: scopeWH)
        let leftBotRect = CGRect.init(x: x-halfScopeWH, y: maxY-halfScopeWH, width: scopeWH, height: scopeWH)
        let rightTopRect = CGRect.init(x: maxX-halfScopeWH, y: y-halfScopeWH, width: scopeWH, height: scopeWH)
        let rightBotRect = CGRect.init(x: maxX-halfScopeWH, y: maxY-halfScopeWH, width: scopeWH, height: scopeWH)
        
        let leftMidRect = CGRect.init(x: x-halfScopeWH, y: midY-halfScopeWH, width: scopeWH, height: scopeWH)
        let rightMidRect = CGRect.init(x: maxX-halfScopeWH, y: midY-halfScopeWH, width: scopeWH, height: scopeWH)
        
        let topMidRect = CGRect.init(x: midX-halfScopeWH, y: y-halfScopeWH, width: scopeWH, height: scopeWH)
        let botMidRect = CGRect.init(x: midX-halfScopeWH, y: maxY-halfScopeWH, width: scopeWH, height: scopeWH)
        
        if leftTopRect.contains(point) ||
            leftBotRect.contains(point) ||
            rightTopRect.contains(point) ||
            rightBotRect.contains(point) ||
            (self.isShowMidDot() && leftMidRect.contains(point)) ||
            (self.isShowMidDot() && rightMidRect.contains(point)) ||
            (self.isShowMidDot() && topMidRect.contains(point)) ||
            (self.isShowMidDot() && botMidRect.contains(point)) {
            return true
        }
        return false
    }
    
}
