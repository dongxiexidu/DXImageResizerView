//
//  DXImageResizerView.swift
//  DXImageResizerView
//
//  Created by fashion on 2018/12/1.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

/**
 * 层级结构
 - JPImageresizerView（self）
 - scrollView
 - imageView（裁剪的imageView）
 - frameView（绘制裁剪边框的view）
 * scrollView与frameView的frame一致
 */

class DXImageResizerView: UIView {

    /// 遮罩样式，目前初始化后不可再更改
    var maskType : DXImageResizerMaskType{
        get{
            return self.frameView.maskType
        }
    }
    
    /// 边框样式
    var borderStyle : DXImageResizerBorderStyle = .concise{
//        get{
//            return self.frameView.borderStyle
//        }
//        set{
//            self.frameView.updateBorderType(borderType:borderStyle)
//        }
        didSet{
            frameView.updateBorderType(borderType:borderStyle)
        }
        
    }
    
    internal var frameView: DXImageResizerFrameView!
    internal var imageView : UIImageView!
    internal var scrollView : UIScrollView!
    
    /// 动画曲线（默认是线性Linear）
    var animationCurve : DXAnimationCurve{
        get{
            return DXAnimationCurve.linear
        }
        
        set{
            if frameView != nil {
                frameView.animationCurve = animationCurve
            }
            
            switch animationCurve {
            case .easeInOut:
                _animationOption = UIView.AnimationOptions.curveEaseInOut
            case .easeIn:
                _animationOption = UIView.AnimationOptions.curveEaseIn
            case .easeOut:
                _animationOption = UIView.AnimationOptions.curveEaseOut
            case .linear:
                _animationOption = UIView.AnimationOptions.curveLinear
            }
        }
    }
    
    /// 裁剪的图片
    var resizeImage : UIImage!{
        didSet{
            self.imageView.image = resizeImage
            updateSubviewLayouts()
        }
    }
    
    /// 裁剪线颜色
    var strokeColor : UIColor = UIColor.white{
//        get{
//            return frameView.strokeColor
//        }
//        set{
//            frameView.strokeColor = strokeColor
//        }
        didSet{
            frameView.strokeColor = strokeColor
        }
        
    }
    
    var _bgColor : UIColor = UIColor.black
    /// 背景颜色
    var bgColor : UIColor {
        get{
            return _bgColor
        }
        set{
            if bgColor == UIColor.clear {
                _bgColor = bgColor
            }
            self.backgroundColor = bgColor
            if frameView != nil {
                frameView.fillColor = bgColor
            }
        }
    }
    
    /// 遮罩颜色的透明度（背景颜色 * 透明度）
    var maskAlpha : CGFloat = 0.5{
//        get {
//            return frameView.maskAlpha
//        }
//        set{
//            if frameView != nil {
//                frameView.maskAlpha = maskAlpha
//            }
//        }
        didSet{
            if frameView != nil {
                frameView.maskAlpha = maskAlpha
            }
        }
        
    }
    
    // 裁剪宽高比（0则为任意比例，可控8个方向，固定比例为4个方向）
    var resizeWHScale : CGFloat = 0{
//        get {
//            return frameView.resizeWHScale
//        }
//        set{
//            if frameView != nil {
//                frameView.setResizeWHScale(resizeWHScale: resizeWHScale, animated: true)
//            }
//        }
        
        didSet{
            if frameView != nil {
                frameView.setResizeWHScale(resizeWHScale: resizeWHScale, animated: true)
            }
        }
        
    }
    /// 裁剪图片与裁剪区域的垂直边距
    var verBaseMargin : CGFloat = 0 {
        didSet{
            updateSubviewLayouts()
        }
    }
    
    /// 裁剪图片与裁剪区域的水平边距
    var horBaseMargin : CGFloat = 0 {
        didSet{
            updateSubviewLayouts()
        }
    }
    var _isClockwiseRotation : Bool = false
    /// 是否顺时针旋转（默认逆时针）
    var isClockwiseRotation : Bool = false{
        didSet{
            if _isClockwiseRotation == isClockwiseRotation {
                return
            }
            _isClockwiseRotation = isClockwiseRotation
            self.allDirections.exchangeObject(at: 1, withObjectAt: 3)
            if self.directionIndex == 1 {
                self.directionIndex = 3
            } else {
                self.directionIndex = 1
            }
        }
    }
    /// 是否锁定裁剪区域（锁定后无法拖动裁剪区域）
    var isLockResizeFrame : Bool = false{
//        get{
//            return !self.frameView.panGR.isEnabled
//        }
//        set{
//            self.frameView.panGR.isEnabled = !isLockResizeFrame
//        }
        didSet{
            frameView.panGR.isEnabled = !isLockResizeFrame
        }
        
    }
    /// 旋转后，是否自动缩放至合适尺寸（默认当图片的宽度比高度小时为YES）
    var isRotatedAutoScale : Bool = true{
        didSet{
            if frameView != nil {
                frameView.isRotatedAutoScale = isRotatedAutoScale
            }
        }
    }
    
    /// 垂直镜像，沿着Y轴旋转180°
    var verticalityMirror : Bool = false{
        didSet{
            setVerticalityMirror(verticalMirror: verticalityMirror, animated: false)
        }
    }
    
    /// 垂直镜像，沿着Y轴旋转180°
    var horizontalMirror : Bool = false{
        didSet{
            setVerticalityMirror(verticalMirror: verticalityMirror, animated: false)
        }
    }
    
    
    internal var allDirections : NSMutableArray = NSMutableArray.init()
    internal var directionIndex : Int = 0
    
    internal var _contentInsets : UIEdgeInsets = .zero
    internal var _animationOption : UIView.AnimationOptions = .curveEaseInOut
    internal var _contentSize : CGSize = .zero
    
    private func setResizeWHScale(resizeWHScale : CGFloat, animated: Bool) {
        self.frameView.setResizeWHScale(resizeWHScale: resizeWHScale, animated: animated)
    }
    private func setVerticalityMirror(verticalMirror : Bool) {
        setVerticalityMirror(verticalMirror: verticalMirror, animated: false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: init method
extension DXImageResizerView {
    public class func imageResizerView(configure : DXImageResizerConfigure,
                                       imageResizerIsCanRecovery: @escaping DXImageResizerIsCanRecoveryBlock,
                                       imageResizerIsPrepareToScale : @escaping DXImageResizerIsPrepareToScaleBlock)->DXImageResizerView{

        let resizerView = DXImageResizerView.init(resizeImage: configure.resizeImage,
                                                  frame: configure.viewFrame,
                                                  maskType: configure.maskType,
                                                  borderStyle: configure.borderStyle,
                                                  animationCurve: configure.animationCurve,
                                                  strokeColor: configure.strokeColor,
                                                  bgColor: configure.bgColor,
                                                  maskAlpha: configure.maskAlpha,
                                                  verBaseMargin: configure.verBaseMargin,
                                                  horBaseMargin: configure.horBaseMargin,
                                                  resizeWHScale: configure.resizeWHScale,
                                                  contentInsets: configure.contentInsets,
                                                  imageResizerIsCanRecovery: imageResizerIsCanRecovery,
                                                  imageResizerIsPrepareToScale: imageResizerIsPrepareToScale)
        
        return resizerView

    }
    
    convenience init(resizeImage: UIImage,
                     frame: CGRect,
                     maskType: DXImageResizerMaskType,
                     borderStyle: DXImageResizerBorderStyle,
                     animationCurve: DXAnimationCurve,
                     strokeColor : UIColor,
                     bgColor : UIColor,
                     maskAlpha : CGFloat,
                     verBaseMargin : CGFloat,
                     horBaseMargin : CGFloat,
                     resizeWHScale : CGFloat,
                     contentInsets : UIEdgeInsets,
                     imageResizerIsCanRecovery: @escaping DXImageResizerIsCanRecoveryBlock,
                     imageResizerIsPrepareToScale : @escaping DXImageResizerIsPrepareToScaleBlock) {
        
        self.init(frame: frame)
        
        self.verBaseMargin = verBaseMargin
        self.horBaseMargin = horBaseMargin
        self._contentInsets = contentInsets
        let width : CGFloat = self.bounds.size.width - _contentInsets.left - _contentInsets.right
        let height : CGFloat = self.bounds.size.height - _contentInsets.top - _contentInsets.bottom
        _contentSize = CGSize.init(width: width, height: height)
        if maskType == .lightBlur {
            self.bgColor = UIColor.white
        } else if maskType == .darkBlur {
            self.bgColor = UIColor.black
        } else {
            self.bgColor = bgColor
        }
        self.animationCurve = animationCurve
        setupBase()
        setupScorllView()
        setupImageView(image: resizeImage)
        setupFrameView(maskType: maskType,
                       borderStyle: borderStyle,
                       animationCurve: animationCurve,
                       strokeColor: strokeColor,
                       maskAlpha: maskAlpha,
                       resizeWHScale: resizeWHScale,
                       isCanRecoveryBlock: imageResizerIsCanRecovery,
                       isPrepareToScaleBlock: imageResizerIsPrepareToScale)
    }
    
    func setupBase() {
        self.clipsToBounds = true
        self.autoresizingMask = UIView.AutoresizingMask.init(rawValue: 0)
        let array = [DXImageResizerRotationDirection.verticalUp,
                              DXImageResizerRotationDirection.horizontalLeft,
                              DXImageResizerRotationDirection.verticalDown,
                              DXImageResizerRotationDirection.horizontalRight]
        
        self.allDirections.addObjects(from: array)
    }
    // MARK: setup scrollView
    func setupScorllView()  {
        let h = _contentSize.height;
        let w = h * h / _contentSize.width;
        let x = _contentInsets.left + (self.bounds.size.width - w) * 0.5;
        let y = _contentInsets.top;
        let scrollView = UIScrollView.init()
        scrollView.frame = CGRect.init(x: x, y: y, width: w, height: h)
        scrollView.delegate = self;
        scrollView.minimumZoomScale = 1.0;
        scrollView.maximumZoomScale = CGFloat(MAXFLOAT)
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.autoresizingMask = UIView.AutoresizingMask.init(rawValue: 0)
        scrollView.clipsToBounds = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        self.addSubview(scrollView)
        self.scrollView = scrollView
    }
    
    
    func setupImageView(image: UIImage) {
        let width : CGFloat = self.frame.size.width - _contentInsets.left - _contentInsets.right
        let height : CGFloat = self.frame.size.height - _contentInsets.top - _contentInsets.bottom
        let maxW : CGFloat = width - 2 * self.horBaseMargin
        let maxH : CGFloat = height - 2 * self.verBaseMargin
        let whScale : CGFloat = image.size.width / image.size.height
        var w : CGFloat = maxW
        var h : CGFloat = w / whScale
        if h > maxH {
            h = maxH;
            w = h * whScale;
        }
        
        let imageView = UIImageView.init(image: image)
        imageView.frame = CGRect.init(x: 0, y: 0, width: w, height: h)
        imageView.isUserInteractionEnabled = true
        self.scrollView.addSubview(imageView)
        self.imageView = imageView
        
        self.isRotatedAutoScale = h > w
        
        let verticalInset = (self.scrollView.bounds.size.height - h) * 0.5
        let horizontalInset = (self.scrollView.bounds.size.width - w) * 0.5
        self.scrollView.contentSize = imageView.bounds.size
        
        self.scrollView.contentInset = .init(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
        self.scrollView.contentOffset = CGPoint.init(x: -horizontalInset, y: -verticalInset)
        
    }
    
    func setupFrameView(maskType: DXImageResizerMaskType,
                        borderStyle: DXImageResizerBorderStyle,
                        animationCurve: DXAnimationCurve,
                        strokeColor: UIColor,
                        maskAlpha: CGFloat,
                        resizeWHScale: CGFloat,
                        isCanRecoveryBlock: @escaping DXImageResizerIsCanRecoveryBlock,
                        isPrepareToScaleBlock : @escaping DXImageResizerIsPrepareToScaleBlock){
        
        let frameView = DXImageResizerFrameView.init(frame: self.scrollView.frame,
                                                     contentSize: _contentSize,
                                                     maskType: maskType,
                                                     borderStyle: borderStyle,
                                                     animationCurve: animationCurve,
                                                     strokeColor: strokeColor,
                                                     fillColor: self.bgColor,
                                                     maskAlpha: maskAlpha,
                                                     verBaseMargin: verBaseMargin,
                                                     horBaseMargin: horBaseMargin,
                                                     resizeWHScale: resizeWHScale,
                                                     scrollView: self.scrollView,
                                                     imageView: self.imageView,
                                                     imageResizerIsCanRecovery: isCanRecoveryBlock, imageResizerIsPrepareToScale: isPrepareToScaleBlock)
        
        
        frameView.isRotatedAutoScale = self.isRotatedAutoScale
        frameView.isVerticalityMirror = { [weak self] in
            guard let self = self else { return false}
            
            return self.verticalityMirror
        }
        frameView.isHorizontalMirror = { [weak self] in
            guard let self = self else { return false}
            
            return self.horizontalMirror
        }
        self.addSubview(frameView)
        self.frameView = frameView
    }
    
}

// MARK: UIScrollViewDelegate
extension DXImageResizerView : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.frameView.startImageResizer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.frameView.endedImageResizer()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.frameView.startImageResizer()
    }
    
}

// MARK: private method
extension DXImageResizerView {
    
    internal func updateSubviewLayouts() {
        self.directionIndex = 0
        self.scrollView.layer.transform = CATransform3DIdentity
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale
        
        let maxW : CGFloat = self.frame.size.width - 2 * self.horBaseMargin
        let maxH : CGFloat = self.frame.size.height - 2 * self.verBaseMargin
        let whScale : CGFloat = self.imageView.image!.size.width / self.imageView.image!.size.height
        var w : CGFloat = maxW
        var h : CGFloat = w / whScale
        if h > maxH {
            h = maxH
            w = h * whScale
        }
        self.imageView.frame = CGRect.init(x: 0, y: 0, width: w, height: h)
        let verticalInset = (self.scrollView.bounds.size.height - h) * 0.5
        let horizontalInset = (self.scrollView.bounds.size.width - w) * 0.5
        self.scrollView.contentSize = self.imageView.bounds.size
        self.scrollView.contentInset = .init(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
        self.scrollView.contentOffset = CGPoint.init(x: -horizontalInset, y: -verticalInset)
        self.frameView.updateImageResizerFrameWithVerBaseMargin(verBaseMargin: self.verBaseMargin, horBaseMargin: self.horBaseMargin)
    }
}
