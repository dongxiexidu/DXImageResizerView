//
//  DXImageResizerView+PublicMethod.swift
//  DXImageResizerView
//
//  Created by fashion on 2018/12/1.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

// MARK: public method
extension DXImageResizerView {
    
    public func setVerticalityMirror(verticalMirror : Bool, animated: Bool) {
        
        if self.frameView.isPrepareToScale {
            // 裁剪区域预备缩放至适合位置，镜像功能暂不可用，此时应该将镜像按钮设为不可点或隐藏
            return
        }
        if self.verticalityMirror == verticalMirror {
            return
        }
        self.verticalityMirror = verticalMirror
        setMirror(isHorizontalMirror: false, animated: animated)
    }
    
    public func setHorizontalMirror(horizontalMirror : Bool, animated: Bool) {
        
        if self.frameView.isPrepareToScale {
            // 裁剪区域预备缩放至适合位置，镜像功能暂不可用，此时应该将镜像按钮设为不可点或隐藏
            return
        }
        if self.horizontalMirror == horizontalMirror {
            return
        }
        self.horizontalMirror = horizontalMirror
        setMirror(isHorizontalMirror: true, animated: animated)
    }
    
    public func setMirror(isHorizontalMirror : Bool, animated : Bool) {
        var transform : CATransform3D = self.layer.transform
        var mirror : Bool = false
        if isHorizontalMirror {
            transform = CATransform3DRotate(transform, CGFloat.pi, 1, 0, 0)
            mirror = self.horizontalMirror
        } else {
            transform = CATransform3DRotate(transform, CGFloat.pi, 0, 1, 0)
            mirror = self.verticalityMirror
        }
        
        self.frameView.willMirror(animated: animated)
        
        let animationBlock = {[weak self] (aTransform : CATransform3D) in
            guard let self = self else { return }
            self.layer.transform = aTransform
            if isHorizontalMirror {
                self.frameView.horizontalMirror(diffX: mirror ? self._contentInsets.bottom : self._contentInsets.top)
                
            } else {
                self.frameView.verticalityMirror(diffX: mirror ? self._contentInsets.right : self._contentInsets.left)
            }
        }
        
        if animated {
            // 做3d旋转时会遮盖住上层的控件，设置为-400即可
            self.layer.zPosition = -400
            transform.m34 = 1.0 / 1500.0
            if isHorizontalMirror {
                transform.m34 *= -1.0
            }
            if mirror {
                transform.m34 *= -1.0
            }
            
            UIView.animate(withDuration: 0.45, delay: 0, options: _animationOption, animations: {
                animationBlock(transform)
            }, completion: { (finished) in
                self.layer.zPosition = 0
                self.frameView.mirrorDone()
            })
        }else{
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            animationBlock(transform)
            CATransaction.commit()
            self.frameView.mirrorDone()
        }
        
    }
    
    
    /// 同时更新图片、垂直边距和水平边距
    public func updateResizeImage(resizeImage: UIImage, verBaseMargin: CGFloat, horBaseMargin: CGFloat) {
        self.imageView.image = resizeImage
        self.verBaseMargin = verBaseMargin
        self.horBaseMargin = horBaseMargin
        updateSubviewLayouts()
    }
    
    /// 旋转90度，支持4个方向，分别是垂直向上、水平向左、垂直向下、水平向右
    public func rotation() {
        if self.frameView.isPrepareToScale {
            // 裁剪区域预备缩放至适合位置，旋转功能暂不可用，此时应该将旋转按钮设为不可点或隐藏
            return
        }
        
        self.directionIndex += 1
        if self.directionIndex > self.allDirections.count - 1 {
            self.directionIndex = 0
        }
        let direction : DXImageResizerRotationDirection = self.allDirections[self.directionIndex] as! DXImageResizerRotationDirection
        var scale : CGFloat = 1
        if self.isRotatedAutoScale {
            if direction == .horizontalLeft || direction == .horizontalRight {
                scale = self.frame.size.width / self.scrollView.bounds.size.height
            }else{
                scale = self.scrollView.bounds.size.height / self.frame.size.width
            }
        }
        let angle : CGFloat = (self.isClockwiseRotation ? 1.0 : -1.0) * CGFloat.pi * 0.5
        
        var svTransform : CATransform3D = self.scrollView.layer.transform
        svTransform = CATransform3DScale(svTransform, scale, scale, 1)
        svTransform = CATransform3DRotate(svTransform, angle, 0, 0, 1)
        
        var fvTransform : CATransform3D = self.frameView.layer.transform
        fvTransform = CATransform3DScale(fvTransform, scale, scale, 1)
        fvTransform = CATransform3DRotate(fvTransform, angle, 0, 0, 1)
        
        UIView.animate(withDuration: 0.23, delay: 0, options: _animationOption, animations: {
            self.scrollView.layer.transform = svTransform
            self.frameView.layer.transform = fvTransform
            self.frameView.rotation(direction: direction, rotationDuration: 0.23)
        }, completion: nil)
        
    }
    public func recovery() {
        if self.frameView.isCanRecovery == false{
            // 已经是初始状态，不需要重置
            return
        }
        self.frameView.willRecovery()
        
        self.directionIndex = 0
        
        horizontalMirror = false
        verticalityMirror = false
        
        let x : CGFloat = (_contentSize.width - self.scrollView.bounds.size.width) * 0.5 + _contentInsets.left
        let y : CGFloat = (_contentSize.height - self.scrollView.bounds.size.height) * 0.5 + _contentInsets.top
        var frames = self.scrollView.bounds
        frames.origin.x = x
        frames.origin.y = y
        
        // 做3d旋转时会遮盖住上层的控件，设置为-400即可
        self.layer.zPosition = -400
        
        UIView.animate(withDuration: 0.45, delay: 0, options: _animationOption, animations: {
            self.layer.transform = CATransform3DIdentity
            self.scrollView.layer.transform = CATransform3DIdentity
            self.frameView.layer.transform = CATransform3DIdentity
            
            self.scrollView.frame = frames
            self.frameView.frame = frames
            self.frameView.recovery(duration: 0.45)
            
        }, completion: { (finished) in
            self.frameView.recoveryDone()
            //默认值是0 来固定层级 值越高view/layer的层级就越高，值越低就越低
            self.layer.zPosition = 0
        })
        
    }
    
    public func originImageResizer(completion : ((UIImage?)->())?){
        imageResizer(completion: completion, isOriginImageSize: true, referenceWidth: 0)
    }
    public func imageResizer(completion : ((UIImage?)->())?, referenceWidth : CGFloat){
        imageResizer(completion: completion, isOriginImageSize: false, referenceWidth: referenceWidth)
    }
    public func imageResizer(completion : ((UIImage?)->())?){
        imageResizer(completion: completion, isOriginImageSize: false, referenceWidth: 0)
    }
    public func imageResizer(completion : ((UIImage?)->())?,isOriginImageSize : Bool, referenceWidth : CGFloat){
        if self.frameView.isPrepareToScale {
            // 裁剪区域预备缩放至适合位置，裁剪功能暂不可用，此时应该将裁剪按钮设为不可点或隐藏
            completion?(nil)
            return
        }
        self.frameView.imageResizer(completion: completion, isOriginImageSize: isOriginImageSize, referenceWidth: referenceWidth)
    }
}
