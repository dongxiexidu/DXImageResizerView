//
//  UIImage+Orientation.swift
//  DXImageResizerView
//
//  Created by fashion on 2018/11/30.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

extension UIImage {
    
    public func dx_fixOrientation() -> UIImage?{
        printLog("")
        if imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity

        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        switch imageOrientation {
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -CGFloat.pi/2)
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat.pi)
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx : CGContext = CGContext.init(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: self.cgImage!.bytesPerRow, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect.init(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height))
            break
        }
        if let cgImage = ctx.makeImage(){
            let img = UIImage.init(cgImage: cgImage)
            return img
        }
        return nil
    }
    
    public func dx_rotate(orientation : UIImage.Orientation) -> UIImage? {
        printLog("")
        if let cgImage = self.cgImage {
            var bounds : CGRect = CGRect.init(x: 0, y: 0, width: cgImage.width, height: cgImage.height)
            let rect : CGRect = bounds
            var transform = CGAffineTransform.identity
            
            switch imageOrientation {
            case .up:
                return self
            case .upMirrored:
                transform = transform.translatedBy(x: rect.size.width, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            case .down:
                transform = transform.translatedBy(x: rect.size.width, y: rect.size.height)
                transform = transform.rotated(by: CGFloat.pi)
            case .downMirrored:
                transform = transform.translatedBy(x: 0 , y: rect.size.height)
                transform = transform.scaledBy(x: 1, y: -1)
            case .left:
                bounds = dx_swapRectWidthHeight(rect: bounds)
                transform = transform.translatedBy(x: 0, y: self.size.width)
                transform = transform.rotated(by: 3*CGFloat.pi/2)
            case .leftMirrored:
                bounds = dx_swapRectWidthHeight(rect: bounds)
                transform = transform.translatedBy(x: rect.size.width, y: rect.size.height)
                transform = transform.scaledBy(x: -1, y: -1)
                transform = transform.rotated(by: 3*CGFloat.pi/2)
            case .right:
                bounds = dx_swapRectWidthHeight(rect: bounds)
                transform = transform.translatedBy(x: self.size.height, y: 0)
                transform = transform.rotated(by: CGFloat.pi/2)
            case .rightMirrored:
                bounds = dx_swapRectWidthHeight(rect: bounds)
                transform = transform.scaledBy(x: -1, y: 1)
                transform = transform.rotated(by: CGFloat.pi/2)
            default:
                return self
            }
            var newImage : UIImage?
            UIGraphicsBeginImageContext(bounds.size)
            let ctx = UIGraphicsGetCurrentContext()
            
            switch imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                ctx?.scaleBy(x: -1, y: 1)
                ctx?.translateBy(x: -rect.size.height, y: 0)
            default:
                ctx?.scaleBy(x: 1, y: 1)
                ctx?.translateBy(x: 0, y: -rect.size.height)
            }
            
            ctx?.concatenate(transform)
            ctx?.draw(cgImage, in: rect)
            
            newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }

    
    public func dx_verticalMirror() -> UIImage?{
        printLog("")
        return dx_rotate(orientation: UIImage.Orientation.upMirrored)
    }
    public func dx_horizontalMirror() -> UIImage?{
        printLog("")
        return dx_rotate(orientation: UIImage.Orientation.downMirrored)
    }
    
    public func dx_swapRectWidthHeight(rect: CGRect) -> CGRect{
        printLog("")
        var tmpRect = rect
        tmpRect.size.width = rect.size.height
        tmpRect.size.height = rect.size.width
        return tmpRect
    }
    
}
