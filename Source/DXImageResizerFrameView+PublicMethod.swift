//
//  DXImageResizerFrameView+PublicMethod.swift
//  DXImageResizerView
//
//  Created by fashion on 2018/11/30.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

extension DXImageResizerFrameView{
    // MARK: - puild method
    
    public func recovery(duration : TimeInterval) {
        printLog("")
        updateRotationDirection(direction: .verticalUp)
        let adjustResizeFrames : CGRect = _isArbitrarily ? baseImageResizerFrame() : adjustResizeFrame()
        
        let contentInset = scrollViewContentInsetWithAdjustResizeFrame(adjustResizeFrame: adjustResizeFrames)
        let minZoomScale : CGFloat = scrollViewMinZoomScaleWithResizeSize(size: adjustResizeFrames.size)
        let contentOffsetX : CGFloat = -contentInset.left + (_baseImageW * minZoomScale - adjustResizeFrames.size.width) * 0.5;
        let contentOffsetY : CGFloat = -contentInset.top + (_baseImageH * minZoomScale - adjustResizeFrames.size.height) * 0.5
        
        updateImageResizerFrame(resizerFrame: adjustResizeFrames, animateDuration: duration)
        
        self.scrollView.minimumZoomScale = minZoomScale
        self.scrollView.zoomScale = minZoomScale
        self.scrollView.contentInset = contentInset
        self.scrollView.contentOffset = CGPoint.init(x: contentOffsetX, y: contentOffsetY)
    }
    
    public func recoveryDone() {
        printLog("")
        updateImageResizerFrame(animateDuration: -1.0)
        self.window?.isUserInteractionEnabled = true
    }
    
    public func mirrorDone() {
        printLog("")
        hideOrShowBlurEffect(isHiden: false, animationDuration: TimeInterval(_defaultDuration))
        checkIsCanRecovery()
        self.window?.isUserInteractionEnabled = true
    }
    public func willRecovery() {
        printLog("")
        self.window?.isUserInteractionEnabled = false
        removeTimer()
    }
    
    public func updateBorderType(borderType: DXImageResizerBorderStyle){
        printLog(borderType)
        
        self.borderStyle = borderType
        updateBorderStyle()
        updateStrokeColor()
        updateImageResizerFrame(resizerFrame: _imageResizerFrame, animateDuration: -1.0)
    }
    
    public func updateImageResizerFrameWithVerBaseMargin(verBaseMargin : CGFloat,horBaseMargin : CGFloat){
        printLog("")
        self.verBaseMargin = verBaseMargin
        self.horBaseMargin = horBaseMargin
        self.layer.transform = CATransform3DIdentity
        updateImageOriginFrameWithDirection(rotationDirection: .verticalUp)
    }
    
    public func startImageResizer() {
        printLog("")
        self.isPrepareToScale = true
        removeTimer()
        hideOrShowBlurEffect(isHiden: true, animationDuration: 0.2)
        hideOrShowBorderLine(isHiden: true, animationDuration: 0.2)
    }
    
    public func endedImageResizer() {
        let contentInset = scrollViewContentInsetWithAdjustResizeFrame(adjustResizeFrame: self.imageResizerFrame)
        printLog(contentInset)
        self.scrollView.contentInset = contentInset
        addTimer()
    }
    public func rotation(direction : DXImageResizerRotationDirection, rotationDuration: TimeInterval) {
        printLog("")
        _isRotation = true
        removeTimer()
        updateRotationDirection(direction: direction)
        updateImageResizerFrame(animateDuration: rotationDuration)
    }
    
    public func willMirror(animated : Bool) {
        printLog("")
        self.window?.isUserInteractionEnabled = false
        if animated {
            hideOrShowBlurEffect(isHiden: true, animationDuration: -1.0)
        }
    }
    
    public func verticalityMirror(diffX : CGFloat) {
        printLog("")
        var w = !self.isHorizontalDirection ? self.bounds.size.width : self.bounds.size.height
        w *= self.sizeScale
        let x = (_contentSize.width - w) * 0.5 + diffX
        var frames = self.frame
        frames.origin.x = x
        
        self.scrollView.frame = frames
        self.frame = frames
    }
    
    public func horizontalMirror(diffY : CGFloat) {
        printLog(diffY)
        var h = !self.isHorizontalDirection ? self.bounds.size.height : self.bounds.size.width
        h *= self.sizeScale
        let y = (_contentSize.height - h) * 0.5 + diffY
        var frames = self.frame
        frames.origin.y = y
        
        self.scrollView.frame = frames
        self.frame = frames
    }
    
    public func imageResizer(completion: ((UIImage?)->())?, isOriginImageSize: Bool, referenceWidth: CGFloat) {
        printLog("")
        if completion == nil {
            return
        }
        var referenceWidths = referenceWidth
        var orientation : UIImage.Orientation
        switch self.rotationDirection {
        case .horizontalLeft:
            orientation = UIImage.Orientation.left
        case .verticalDown:
            orientation = UIImage.Orientation.down
        case .horizontalRight:
            orientation = UIImage.Orientation.right
        default:
            orientation = UIImage.Orientation.up
            break
        }
        var isVerticalityMirror = self.isVerticalityMirror?() ?? false
        var isHorizontalMirror = self.isHorizontalMirror?() ?? false
        let isHorizontalDirection = self.isHorizontalDirection
        if isHorizontalDirection {
            let temp = isVerticalityMirror
            isVerticalityMirror = isHorizontalMirror
            isHorizontalMirror = temp
        }
        var image = self.imageView.image!
        
        let imageScale : CGFloat = image.scale
        let imageWidth : CGFloat = image.size.width * imageScale
        let imageHeight : CGFloat = image.size.height * imageScale
        let scale = imageWidth / self.imageView.bounds.size.width
        
        let cropFrame = (self.isCanRecovery || self.resizeWHScale > 0) ? convert(self.imageResizerFrame, to: self.imageView) : self.imageView.bounds

        
        if referenceWidths > 0 {
            let maxWidth = max(imageWidth, self.imageView.bounds.size.width)
            let minWidth = min(imageWidth, self.imageView.bounds.size.width)
            if referenceWidth > maxWidth {
                referenceWidths = maxWidth
            }
            if referenceWidth < minWidth {
                referenceWidths = minWidth
            }
        }else{
            referenceWidths = self.imageView.bounds.size.width
        }
        
        DispatchQueue.global().async {
            image = image.dx_fixOrientation()!
            if isVerticalityMirror {
                image = image.dx_verticalMirror()!
            }
            if isHorizontalMirror {
                image = image.dx_horizontalMirror()!
            }
            // 宽高比不变，所以宽度高度的比例是一样
            let orgX : CGFloat = cropFrame.origin.x * scale
            let orgY: CGFloat = cropFrame.origin.y * scale
            let width: CGFloat = cropFrame.size.width * scale
            let height: CGFloat = cropFrame.size.height * scale
            var cropRect = CGRect.init(x: orgX, y: orgY, width: width, height: height)
            
            if orgX < 0 {
                cropRect.origin.x = 0
                cropRect.size.width += -orgX
            }
            
            if orgY < 0 {
                cropRect.origin.y = 0
                cropRect.size.height += -orgY
            }
            let cropMaxX = cropRect.maxX
            if cropMaxX > imageWidth {
                let diffW = cropMaxX - imageWidth
                cropRect.size.width -= diffW
            }
            
            let cropMaxY = cropRect.maxY
            if cropMaxY > imageHeight {
                let diffH = cropMaxY - imageHeight
                cropRect.size.height -= diffH
            }
            
            if isVerticalityMirror {
                cropRect.origin.x = imageWidth - cropRect.maxX
            }
            if isHorizontalMirror {
                cropRect.origin.y = imageHeight - cropRect.maxY
            }
            guard let cgImage = image.cgImage else{ return }
            guard let cgImg = cgImage.cropping(to: cropRect) else{ return }
            let resizeImg = UIImage.init(cgImage: cgImg)
            
            guard let resizedImage = resizeImg.dx_rotate(orientation: orientation) else{ return }
            
            if isOriginImageSize {
                DispatchQueue.main.async {
                    completion?(resizedImage)
                }
                return
            }
            
            // 有小数的情况下，边界会多出白线，需要把小数点去掉
            let cropScale = imageWidth / referenceWidths
            let cropSize : CGSize = CGSize.init(width: resizedImage.size.width / cropScale, height: resizedImage.size.height / cropScale)
            /**
             * 参考：http://www.jb51.net/article/81318.htm
             * 这里要注意一点CGContextDrawImage这个函数的坐标系和UIKIt的坐标系上下颠倒，需对坐标系处理如下：
             - 1.CGContextTranslateCTM(context, 0, cropSize.height);
             - 2.CGContextScaleCTM(context, 1, -1);
             */

            
            let deviceScale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(cropSize, false, deviceScale)
            let ctx = UIGraphicsGetCurrentContext()
            ctx?.translateBy(x: 0, y: cropSize.height)
            ctx?.scaleBy(x: 1, y: -1)
            ctx?.draw(resizedImage.cgImage!, in: CGRect.init(x: 0, y: 0, width: cropSize.width, height: cropSize.height))
            let newImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            DispatchQueue.main.async {
                completion?(newImg)
            }
        }
    }
    
    
}
