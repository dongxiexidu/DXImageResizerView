//
//  DXImageResizerFrameView.swift
//  DXImageResizerView
//
//  Created by fashion on 2018/11/28.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

struct DXRGBAColor {
    var dx_r : CGFloat
    var dx_g : CGFloat
    var dx_b : CGFloat
    var dx_a : CGFloat
}

enum DXRectHorn {
    case center
    case leftTop
    case leftMid
    case leftBottom
    
    case rightTop
    case rightMid
    case rightBottom
    
    case topMid
    case bottomMid
}

enum DXLinePosition {
    case horizontalTop
    case horizontalBottom
    case verticalLeft
    case verticalRight
}

class DXImageResizerFrameView: UIView {
    
    
    /// 遮罩样式
    var maskType : DXImageResizerMaskType = DXImageResizerMaskType.normal
    
    /// 边框样式
    var borderStyle : DXImageResizerBorderStyle = DXImageResizerBorderStyle.concise{
        didSet{
            var lineW : CGFloat = 0
            if borderStyle == .concise || borderStyle == .conciseWithoutOtherDot {
                if borderStyle == .concise {
                    _ = leftMidDot
                    _ = rightMidDot
                    _ = topMidDot
                    _ = bottomMidDot
                }else{
                    leftMidDot.removeFromSuperlayer()
                    rightMidDot.removeFromSuperlayer()
                    topMidDot.removeFromSuperlayer()
                    bottomMidDot.removeFromSuperlayer()
                }
                horTopLine.removeFromSuperlayer()
                horBottomLine.removeFromSuperlayer()
                verLeftLine.removeFromSuperlayer()
                verRightLine.removeFromSuperlayer()
                self.isHideFrameLine = false
            } else {
                _ = horTopLine
                _ = horBottomLine
                _ = verLeftLine
                _ = verRightLine
                leftMidDot.removeFromSuperlayer()
                rightMidDot.removeFromSuperlayer()
                topMidDot.removeFromSuperlayer()
                bottomMidDot.removeFromSuperlayer()
                lineW = arrLineW / sizeScale
            }
            
            self.leftTopDot.lineWidth = lineW
            self.leftBottomDot.lineWidth = lineW
            self.rightTopDot.lineWidth = lineW
            self.rightBottomDot.lineWidth = lineW
        }
    }

    /// 手势
    var panGR : UIPanGestureRecognizer!
    
    /// 动画曲线
    var animationCurve : DXAnimationCurve = DXAnimationCurve.easeOut{
        didSet{
            switch animationCurve {
            case .easeInOut:
                self.kCAMediaTimingFunction = CAMediaTimingFunctionName.easeInEaseOut.rawValue
                self.animationOption = UIView.AnimationOptions.curveEaseInOut
            case .easeIn:
                self.kCAMediaTimingFunction = CAMediaTimingFunctionName.easeIn.rawValue
                self.animationOption = UIView.AnimationOptions.curveEaseIn
            case .easeOut:
                self.kCAMediaTimingFunction = CAMediaTimingFunctionName.easeOut.rawValue
                self.animationOption = UIView.AnimationOptions.curveEaseOut
            case .linear:
                self.kCAMediaTimingFunction = CAMediaTimingFunctionName.linear.rawValue
                self.animationOption = UIView.AnimationOptions.curveLinear
            }
        }
    }
    
    /// 裁剪线颜色
    var strokeColor : UIColor = UIColor.white{
        didSet{
            let strokeCGColor = strokeColor.cgColor
            let clearCGColor = UIColor.clear.cgColor
            // 显示
            CATransaction.begin()
            // 关闭动画
            CATransaction.setDisableActions(true)
            self.frameLayer?.strokeColor = strokeColor.cgColor
            if borderStyle == .concise || borderStyle == .conciseWithoutOtherDot {
                self.leftTopDot.fillColor = strokeCGColor
                self.leftBottomDot.fillColor = strokeCGColor
                self.rightTopDot.fillColor = strokeCGColor
                self.rightBottomDot.fillColor = strokeCGColor
                
                self.leftTopDot.strokeColor = clearCGColor
                self.leftBottomDot.strokeColor = clearCGColor
                self.rightTopDot.strokeColor = clearCGColor
                self.rightBottomDot.strokeColor = clearCGColor
                
                self.leftMidDot.fillColor = strokeCGColor
                self.rightMidDot.fillColor = strokeCGColor
                self.topMidDot.fillColor = strokeCGColor
                self.bottomMidDot.fillColor = strokeCGColor
            } else {
                
                self.leftTopDot.strokeColor = strokeCGColor
                self.leftBottomDot.strokeColor = strokeCGColor
                self.rightTopDot.strokeColor = strokeCGColor
                self.rightBottomDot.strokeColor = strokeCGColor
                
                self.leftTopDot.fillColor = clearCGColor
                self.leftBottomDot.fillColor = clearCGColor
                self.rightTopDot.fillColor = clearCGColor
                self.rightBottomDot.fillColor = clearCGColor
                
                self.horTopLine.strokeColor = strokeCGColor
                self.horBottomLine.strokeColor = strokeCGColor
                self.verLeftLine.strokeColor = strokeCGColor
                self.verRightLine.strokeColor = strokeCGColor
            }
            CATransaction.commit()
            
        }
    }
    
    
    var _fillColor : UIColor = UIColor.white
    ///
    var fillColor : UIColor {
        get{
            return _fillColor
        }
        set{
            if maskType == .lightBlur {
                _fillColor = UIColor.white
            } else if maskType == .darkBlur {
                _fillColor = UIColor.black
            }
            fillRgba = self.createRGBAColor(color: fillColor)
            _fillColor = UIColor.init(red: fillRgba.dx_r, green: fillRgba.dx_g, blue: fillRgba.dx_b, alpha: fillRgba.dx_a * maskAlpha)
            
            clearColor = UIColor.init(red: fillRgba.dx_r, green: fillRgba.dx_g, blue: fillRgba.dx_b, alpha: 0)
            
            if blurContentView != nil {
                blurContentView.backgroundColor = fillColor
            } else {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                bgLayer?.fillColor = fillColor.cgColor
                CATransaction.commit()
            }
            
        }
    }
    
    /// 遮罩颜色的透明度（背景颜色 * 透明度）
    var maskAlpha : CGFloat = 0.75 {
        didSet{
            if maskAlpha == 0 {
                _fillColor = clearColor
            }else{
                _fillColor = UIColor.init(red: fillRgba.dx_r, green: fillRgba.dx_g, blue: fillRgba.dx_b, alpha: fillRgba.dx_a * maskAlpha)
            }
            if blurContentView != nil {
                blurContentView.backgroundColor = fillColor
            } else {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                bgLayer?.fillColor = fillColor.cgColor
                CATransaction.commit()
            }
        }
    }
    
    var _resizeWHScale : CGFloat = 0
    
    /// 裁剪宽高比（0则为任意比例，可控8个方向，固定比例为4个方向）
    var resizeWHScale : CGFloat = 0 {
        didSet{
            _resizeWHScale = resizeWHScale
            setResizeWHScale(resizeWHScale: resizeWHScale, animated: false)
        }
    }
    
    func setResizeWHScale(resizeWHScale : CGFloat, animated: Bool) {
        var tempResizeWHScale = resizeWHScale
        if resizeWHScale > 0 {
            if self.isHorizontalDirection {
                tempResizeWHScale = 1.0 / resizeWHScale
            }
        }
        if self.resizeWHScale == tempResizeWHScale {
            return
        }
        
        _resizeWHScale = tempResizeWHScale
        self.updateDuration = animated ? self.defaultDuration : -1
        self.isArbitrarily = tempResizeWHScale <= 0
        
        if borderStyle == .concise {
            var midDotOpacity : Float = 1
            if self.isArbitrarily == false {
                midDotOpacity = 0
            }
            self.leftMidDot.opacity = midDotOpacity
            self.rightMidDot.opacity = midDotOpacity
            self.topMidDot.opacity = midDotOpacity
            self.bottomMidDot.opacity = midDotOpacity
        }
        
        if self.superview != nil {
            updateImageOriginFrameWithDirection(rotationDirection: self.rotationDirection)
        }
    }
   
    internal var isVerticalityMirror : (()->Bool)?
    internal var isHorizontalMirror : (()->Bool)?
    
    ///
    var sizeScale : CGFloat = 0
    ///
    var scrollViewMinZoomScale : CGFloat = 0
    
    var _imageResizerFrame : CGRect = CGRect.zero
    ///
    var imageResizerFrame : CGRect = CGRect.zero {
        didSet{
            updateImageResizerFrame(resizerFrame: imageResizerFrame, animateDuration: -1)
        }
    }
    internal var imageResizeX: CGFloat {
        get{
            return imageResizerFrame.origin.x
        }
        set{
            imageResizerFrame.origin.x = imageResizeX
        }
    }
    internal var imageResizeY: CGFloat {
        
        get{
            return imageResizerFrame.origin.y
        }
        set{
            imageResizerFrame.origin.y = imageResizeY
        }
    }
    internal var imageResizeW: CGFloat {
        get{
            return imageResizerFrame.size.width
        }
        set{
            imageResizerFrame.size.width = imageResizeW
        }
    }
    internal var imageResizeH: CGFloat {
        get{
            return imageResizerFrame.size.height
        }
        set{
            imageResizerFrame.size.height = imageResizeH
        }
    }
    
    /// 裁剪图片与裁剪区域的垂直边距
    var verBaseMargin : CGFloat = 10
    
    /// 裁剪图片与裁剪区域的水平边距
    var horBaseMargin : CGFloat = 10
    
    /// 裁剪图片与裁剪区域的水平边距
    var contentInsets : UIEdgeInsets = UIEdgeInsets.zero
    
    /// 是否可以重置
    var isCanRecovery : Bool = false{
        didSet{
            if self.imageResizerIsCanRecovery != nil {
                self.imageResizerIsCanRecovery(isCanRecovery)
            }
        }
    }
    /// 是否顺时针旋转
    var isClockwiseRotation : Bool = false
    /// 是否是水平方向
    var isHorizontalDirection : Bool {
        return rotationDirection == .horizontalLeft || rotationDirection == .horizontalRight
    }
    
    var _isRotatedAutoScale : Bool = false
    ///
    var isRotatedAutoScale : Bool = false{
        didSet{
            if _isRotatedAutoScale == isRotatedAutoScale {
                return
            }
            _isRotatedAutoScale = isRotatedAutoScale
            if self.superview != nil {
                updateMaxResizeFrame(direction: self.rotationDirection)
            }
        }
    }
    ///
    var isPrepareToScale : Bool = false{
        didSet{
            if self.imageResizerIsPrepareToScale != nil {
                self.imageResizerIsPrepareToScale(isPrepareToScale)
            }
        }
    }
    /// 是否预备缩放裁剪区域至适应范围
    /// 当裁剪区域发生变化的开始和结束就会触发该回调
    /// YES：预备缩放，此时裁剪、旋转、镜像功能不可用 NO：没有预备缩放
    var imageResizerIsPrepareToScale : ((Bool)->())!
    /// 是否可以重置的回调
    var imageResizerIsCanRecovery : ((Bool)->())!
    ///
    var rotationDirection : DXImageResizerRotationDirection = .verticalUp
    
    var blurContentView : UIView!
    var blurEffectView : UIVisualEffectView!
    
    private var timer : Timer?
    public var scrollView : UIScrollView!
    internal var imageView : UIImageView!
    
    private var bgLayer : CAShapeLayer?
    private var frameLayer : CAShapeLayer?
    
    private lazy var leftTopDot: CAShapeLayer = {
        return createShapeLayer(lineWidth: 0)
    }()
    private lazy var leftMidDot : CAShapeLayer = {
        return createShapeLayer(lineWidth: 0)
    }()
    private lazy var leftBottomDot : CAShapeLayer = {
        return createShapeLayer(lineWidth: 0)
    }()
    private lazy var rightTopDot : CAShapeLayer = {
        return createShapeLayer(lineWidth: 0)
    }()
    private lazy var rightMidDot : CAShapeLayer = {
        return createShapeLayer(lineWidth: 0)
    }()
    private lazy var rightBottomDot : CAShapeLayer = {
        return createShapeLayer(lineWidth: 0)
    }()
    private lazy var topMidDot : CAShapeLayer = {
        return createShapeLayer(lineWidth: 0)
    }()
    private lazy var bottomMidDot : CAShapeLayer = {
        return createShapeLayer(lineWidth: 0)
    }()
    
    private lazy var horTopLine : CAShapeLayer = {
        return createShapeLayer(lineWidth: 0.5)
    }()
    private lazy var horBottomLine : CAShapeLayer = {
        return createShapeLayer(lineWidth: 0.5)
    }()
    private lazy var verLeftLine : CAShapeLayer = {
        return createShapeLayer(lineWidth: 0.5)
    }()
    private lazy var verRightLine : CAShapeLayer = {
        return createShapeLayer(lineWidth: 0.5)
    }()
    
    var currHorn : DXRectHorn = DXRectHorn.center
    var diagonal : CGPoint = CGPoint.zero
    var originImageFrame : CGRect = CGRect.zero
    var maxResizeFrame : CGRect = CGRect.zero
    
    
    ///
    public var defaultDuration : CGFloat = 0.27
    private var updateDuration : CGFloat = -1.0
    private var kCAMediaTimingFunction : String!
    private var animationOption = UIView.AnimationOptions.curveEaseInOut
    
    private var dotWH : CGFloat = 10
    private var arrLineW : CGFloat = 2.5
    private var arrLength : CGFloat = 20.0
    internal var scopeWH : CGFloat = 50.0
    internal var minImageWH : CGFloat = 70
    internal var _isRotation : Bool = false
    
    public var baseImageW : CGFloat = 0
    public var baseImageH : CGFloat = 0
    
    internal var startResizeW : CGFloat = 0
    internal var startResizeH : CGFloat = 0
    
    private var originWHScale : CGFloat = 0
    
    private var verSizeScale : CGFloat = 0
    private var horSizeScale : CGFloat = 0
    
    private var diffHalfW : CGFloat = 0
    
    /// 任意的
    public var isArbitrarily : Bool = false
    
    private var fillRgba : DXRGBAColor!
    private var clearColor : UIColor = UIColor.clear
    
    private var isHideBlurEffect : Bool = false
    private var isHideFrameLine : Bool = false
    
    private var diffRotLength : CGFloat = 1000
    /// 扩大旋转时的区域（防止旋转时有空白区域）
    private var bgFrame : CGRect = CGRect.zero
    
    internal var contentSize : CGSize = CGSize.zero
    private var isRotation : Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: init
    convenience init(frame: CGRect,
                     contentSize: CGSize,
                     maskType: DXImageResizerMaskType,
                     borderStyle: DXImageResizerBorderStyle,
                     animationCurve: DXAnimationCurve,
                     strokeColor: UIColor,
                     fillColor: UIColor,
                     maskAlpha: CGFloat,
                     verBaseMargin: CGFloat,
                     horBaseMargin: CGFloat,
                     resizeWHScale: CGFloat,
                     scrollView: UIScrollView,
                     imageView: UIImageView,
                     imageResizerIsCanRecovery: @escaping ((Bool)->()),
                     imageResizerIsPrepareToScale: @escaping ((Bool)->())){
    
        self.init(frame: frame)
        
        self.clipsToBounds = false
        self.contentSize = contentSize
        self.maskType = maskType
        self.horBaseMargin = horBaseMargin
        self.verBaseMargin = verBaseMargin
        self.imageResizerIsPrepareToScale = imageResizerIsPrepareToScale
        self.imageResizerIsCanRecovery = imageResizerIsCanRecovery
        
        self.bgFrame = CGRect.init(x: bounds.origin.x - diffRotLength, y: bounds.origin.y - diffRotLength, width: bounds.size.width + diffRotLength * 2, height: bounds.size.height + diffRotLength * 2)
        
        if maskType != .normal {
            let blurContentView = UIView.init(frame: bgFrame)
            self.addSubview(blurContentView)
            self.blurContentView = blurContentView
            
            var blurEffect : UIBlurEffect!
            if maskType == .lightBlur {
                blurEffect = UIBlurEffect.init(style: UIBlurEffect.Style.light)
            }else{
                blurEffect = UIBlurEffect.init(style: UIBlurEffect.Style.dark)
            }
            
            let blurEffectView = UIVisualEffectView.init(effect: blurEffect)
            blurEffectView.frame = blurContentView.bounds
            blurContentView.addSubview(blurEffectView)
            self.blurEffectView = blurEffectView
            
            let bgLayer = CAShapeLayer.init()
            bgLayer.frame = blurContentView.bounds
            bgLayer.fillColor = UIColor.black.cgColor
            blurContentView.layer.mask = bgLayer
            self.bgLayer = bgLayer
            
            
        } else {
            self.bgLayer = self.createShapeLayer(lineWidth: 0)
        }
        self.bgLayer?.fillRule = .evenOdd
        
        let frameLayer = self.createShapeLayer(lineWidth: 0)
        frameLayer.fillColor = UIColor.clear.cgColor
        self.frameLayer = frameLayer
        
        self.borderStyle = borderStyle
        self.animationCurve = animationCurve
        self.scrollView = scrollView
        self.imageView = imageView
        
        self.maskAlpha = maskAlpha
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        
        // ??
        if resizeWHScale == self.resizeWHScale {
            self.resizeWHScale = resizeWHScale - 1.0
        }
        self.resizeWHScale = resizeWHScale
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panHandle(pan:)))
        self.addGestureRecognizer(pan)
        self.panGR = pan

    }
    
    // MARK: life cycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil {
            updateImageOriginFrameWithDirection(rotationDirection: self.rotationDirection)
        }
    }
    
    deinit {
        willDie()
    }
    
    
    
}

extension DXImageResizerFrameView {
    
    
    // MARK: assist method
    func willDie() {
        self.window?.isUserInteractionEnabled = true
        _ = removeTimer()
    }
    public func createShapeLayer(lineWidth: CGFloat) -> CAShapeLayer{
        let layer = CAShapeLayer.init()
        layer.frame = self.bounds
        layer.lineWidth = lineWidth
        self.layer.addSublayer(layer)
        return layer
    }
    
    func isShowMidDot()-> Bool{
        return isArbitrarily && borderStyle == .concise
    }
    
    func dotPath(position : CGPoint) -> UIBezierPath {
        let dotW_H : CGFloat = dotWH / sizeScale
        let dotPath : UIBezierPath = UIBezierPath.init(ovalIn: CGRect.init(x: position.x - dotWH * 0.5, y: position.y - dotWH * 0.5, width: dotW_H, height: dotW_H))
        return dotPath
    }
    
    func arrPath(position: CGPoint, rectHorn: DXRectHorn) -> UIBezierPath {
        var tempPosition = position
        
        let arrLine_W = arrLineW / sizeScale
        let arr_Length =  arrLength / sizeScale
        let path = UIBezierPath.init()
        let halfArrLineW = arrLine_W * 0.5
        var firstPoint = CGPoint.zero
        var secondPoint = CGPoint.zero
        var thirdPoint = CGPoint.zero
        
        switch rectHorn {
        case .leftTop:
            tempPosition.x -= halfArrLineW
            tempPosition.y -= halfArrLineW
            firstPoint = CGPoint.init(x: tempPosition.x, y: tempPosition.y + arr_Length)
            thirdPoint = CGPoint.init(x: tempPosition.x + arr_Length, y: tempPosition.y)
        case .leftBottom:
            tempPosition.x -= halfArrLineW
            tempPosition.y += halfArrLineW
            firstPoint = CGPoint.init(x: tempPosition.x, y: tempPosition.y + arr_Length)
            thirdPoint = CGPoint.init(x: tempPosition.x + arr_Length, y: tempPosition.y)
        case .rightTop:
            tempPosition.x += halfArrLineW
            tempPosition.y -= halfArrLineW
            firstPoint = CGPoint.init(x: tempPosition.x - arr_Length, y: tempPosition.y)
            thirdPoint = CGPoint.init(x: tempPosition.x, y: tempPosition.y + arr_Length)
        case .rightBottom:
            tempPosition.x += halfArrLineW
            tempPosition.y += halfArrLineW
            firstPoint = CGPoint.init(x: tempPosition.x - arr_Length, y: tempPosition.y)
            thirdPoint = CGPoint.init(x: tempPosition.x, y: tempPosition.y - arr_Length)
        default:
            firstPoint = tempPosition
            thirdPoint = tempPosition
        }
        secondPoint = tempPosition
        path.move(to: firstPoint)
        path.addLine(to: secondPoint)
        path.addLine(to: thirdPoint)
        return path
    }
    
    func linePath(linePosition: DXLinePosition, location: CGPoint, length: CGFloat) -> UIBezierPath {
        let path = UIBezierPath.init()
        var point = CGPoint.zero
        switch linePosition {
        case .horizontalTop:
            break
        case .horizontalBottom:
            point = CGPoint.init(x: location.x + length, y: location.y)
        case .verticalLeft:
            break
        case .verticalRight:
            point = CGPoint.init(x: location.x, y: location.y + length)
        }
        path.move(to: location)
        path.addLine(to: point)
        return path
    }
    /// 判断裁剪框是否完全等于原来的imageView
    func imageResizerFrameIsFullImageViewFrame() -> Bool{
        let imageResizerSize : CGSize = self.imageResizerSize()
        let imageViewSize = self.imageViewSize()
        
        return abs(imageResizerSize.width - imageViewSize.width) <= 1 && abs(imageResizerSize.height - imageViewSize.height) <= 1
    }
    /// 判断裁剪框是否等于原来的imageView
    func imageResizerFrameIsEqualImageViewFrame() -> Bool{
        let imageResizerSize : CGSize = self.imageResizerSize()
        let imageViewSize = self.imageViewSize()
        let resizeWHScale = (rotationDirection == .verticalUp || rotationDirection == .verticalDown) ? _resizeWHScale : (1.0 / _resizeWHScale)
        if isArbitrarily || resizeWHScale == originWHScale {
            return abs(imageResizerSize.width - imageViewSize.width) <= 1 && abs(imageResizerSize.height - imageViewSize.height) <= 1
        }else{
            return abs(imageResizerSize.width - imageViewSize.width) <= 1 || abs(imageResizerSize.height - imageViewSize.height) <= 1
        }
    }
    
    //==================
    
    // MARK: private method
    internal func updateImageOriginFrameWithDirection(rotationDirection : DXImageResizerRotationDirection) {
        removeTimer()
        
        self.baseImageW = self.imageView.bounds.size.width
        self.baseImageH = self.imageView.bounds.size.height
        self.verSizeScale = 1.0
        horSizeScale = contentSize.width / self.scrollView.bounds.size.height
        diffHalfW = (self.bounds.size.width - contentSize.width) * 0.5
        let x : CGFloat = (self.bounds.size.width - baseImageW) * 0.5
        let y : CGFloat = (self.bounds.size.height - baseImageH) * 0.5
        originImageFrame = CGRect.init(x: x, y: y, width: baseImageW, height: baseImageH)
        updateRotationDirection(direction: rotationDirection)
        
        updateImageResizerFrame(resizerFrame: baseImageResizerFrame(), animateDuration: TimeInterval(updateDuration))
        updateImageResizerFrame(animateDuration: TimeInterval(updateDuration))
        updateDuration = -1.0;
    }
    
    func updateImageResizerFrame(resizerFrame : CGRect,animateDuration duration: TimeInterval)  {
        
        _imageResizerFrame = resizerFrame
        let imgResizerX : CGFloat = resizerFrame.origin.x
        let imgResizerY : CGFloat = resizerFrame.origin.y
        let imgResizerMidX : CGFloat = resizerFrame.midX
        let imgResizerMidY : CGFloat = resizerFrame.midY
        let imgResizerMaxX : CGFloat = resizerFrame.maxX
        let imgResizerMaxY : CGFloat = resizerFrame.maxY
        
        var leftTopDotPath : UIBezierPath!
        var leftBottomDotPath : UIBezierPath!
        var rightTopDotPath : UIBezierPath!
        var rightBottomDotPath : UIBezierPath!
        
        var leftMidDotPath : UIBezierPath!
        var rightMidDotPath : UIBezierPath!
        var topMidDotPath : UIBezierPath!
        var bottomMidDotPath : UIBezierPath!
        
        var horTopLinePath : UIBezierPath!
        var horBottomLinePath : UIBezierPath!
        var verLeftLinePath : UIBezierPath!
        var verRightLinePath : UIBezierPath!
        
        if borderStyle == .concise || borderStyle == .conciseWithoutOtherDot {
            leftTopDotPath = dotPath(position: CGPoint.init(x: imgResizerX, y: imgResizerY))
            leftBottomDotPath = dotPath(position: CGPoint.init(x: imgResizerX, y: imgResizerMaxY))
            rightTopDotPath = dotPath(position: CGPoint.init(x: imgResizerMaxX, y: imgResizerY))
            rightBottomDotPath = dotPath(position: CGPoint.init(x: imgResizerMaxX, y: imgResizerMaxY))
            
            if borderStyle == .concise {
                leftMidDotPath = dotPath(position: CGPoint.init(x: imgResizerX, y: imgResizerMidY))
                rightMidDotPath = dotPath(position: CGPoint.init(x: imgResizerMaxX, y: imgResizerMidY))
                topMidDotPath = dotPath(position: CGPoint.init(x: imgResizerMidX, y: imgResizerY))
                bottomMidDotPath = dotPath(position: CGPoint.init(x: imgResizerMidX, y: imgResizerMaxY))
            }
        }else{
            
            leftTopDotPath = arrPath(position: CGPoint.init(x: imgResizerX, y: imgResizerY), rectHorn: .leftTop)
            leftBottomDotPath = arrPath(position: CGPoint.init(x: imgResizerX, y: imgResizerMaxY), rectHorn: .leftBottom)
            rightTopDotPath = arrPath(position: CGPoint.init(x: imgResizerMaxX, y: imgResizerY), rectHorn: .rightTop)
            rightBottomDotPath = arrPath(position: CGPoint.init(x: imgResizerMaxX, y: imgResizerMaxY), rectHorn: .leftTop)
            
            let imageResizerW : CGFloat = resizerFrame.size.width
            let imageResizerH : CGFloat = resizerFrame.size.height
            let oneThirdW : CGFloat = imageResizerW / 3.0
            let oneThirdH : CGFloat = imageResizerH / 3.0
            
            horTopLinePath = linePath(linePosition: .horizontalTop, location: CGPoint.init(x: imgResizerX, y: imgResizerY + oneThirdH), length: imageResizerW)
            horBottomLinePath = linePath(linePosition: .horizontalBottom, location: CGPoint.init(x: imgResizerX, y: imgResizerY + oneThirdH * 2), length: imageResizerW)
            verLeftLinePath = linePath(linePosition: .verticalLeft, location: CGPoint.init(x: imgResizerX + oneThirdW, y: imgResizerY), length: imageResizerH)
            verRightLinePath = linePath(linePosition: .verticalRight, location: CGPoint.init(x: imgResizerX + oneThirdW * 2, y: imgResizerY), length: imageResizerH)
            
            let bgPath : UIBezierPath!
            let framePath = UIBezierPath.init(rect: resizerFrame)
            
            if self.blurContentView != nil {
                bgPath = UIBezierPath.init(rect: self.blurContentView.bounds)
                var frame = resizerFrame
                frame.origin.x += diffRotLength
                frame.origin.y += diffRotLength
                bgPath.append(UIBezierPath.init(rect: frame))
            }else{
                bgPath = UIBezierPath.init(rect: self.bgFrame)
                bgPath.append(framePath)
            }
            
            if duration > 0 {
                let layerPathAnimate = { (layer : CAShapeLayer, path: UIBezierPath) in
                    let anim = CABasicAnimation.init(keyPath: "layer.path")
                    anim.fillMode = .backwards
                    
                    anim.fromValue = UIBezierPath.init(cgPath: layer.path!)
                    anim.toValue = path
                    anim.duration = duration
                    anim.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName(rawValue: self.kCAMediaTimingFunction!))
                    layer.add(anim, forKey: "path")
                }
                layerPathAnimate(self.leftTopDot,leftTopDotPath)
                layerPathAnimate(self.leftBottomDot,leftBottomDotPath)
                layerPathAnimate(self.rightTopDot,rightTopDotPath)
                layerPathAnimate(self.rightBottomDot,rightBottomDotPath)
                
                if borderStyle == .concise {
                    layerPathAnimate(self.leftMidDot,leftMidDotPath)
                    layerPathAnimate(self.rightMidDot,rightMidDotPath)
                    layerPathAnimate(self.topMidDot,topMidDotPath)
                    layerPathAnimate(self.bottomMidDot,bottomMidDotPath)
                }else if borderStyle == .concise {
                    layerPathAnimate(self.horTopLine,horTopLinePath)
                    layerPathAnimate(self.horBottomLine,horBottomLinePath)
                    layerPathAnimate(self.verLeftLine,verLeftLinePath)
                    layerPathAnimate(self.verRightLine,verRightLinePath)
                }
                layerPathAnimate(self.bgLayer!, bgPath)
                layerPathAnimate(self.frameLayer!, framePath)
                
            }
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.leftTopDot.path = leftTopDotPath.cgPath
            self.leftBottomDot.path = leftBottomDotPath.cgPath
            self.rightTopDot.path = rightTopDotPath.cgPath
            self.rightBottomDot.path = rightBottomDotPath.cgPath
            
            if borderStyle == .concise {
                self.leftMidDot.path = leftMidDotPath.cgPath
                self.rightMidDot.path = rightMidDotPath.cgPath
                self.topMidDot.path = topMidDotPath.cgPath
                self.bottomMidDot.path = bottomMidDotPath.cgPath
            }else if borderStyle == .classic {
                self.horTopLine.path = horTopLinePath.cgPath
                self.horBottomLine.path = horBottomLinePath.cgPath
                self.verLeftLine.path = verLeftLinePath.cgPath
                self.verRightLine.path = verRightLinePath.cgPath
            }
            self.bgLayer!.path = bgPath.cgPath
            self.frameLayer!.path = framePath.cgPath
            CATransaction.commit()
            
        }
    }
    
    func adjustResizeFrame() -> CGRect{
        let resizeWHScale : CGFloat = self.isArbitrarily ? (self.imageResizeW / self.imageResizeH) : _resizeWHScale
        
        var adjustResizeW : CGFloat = 0
        var adjustResizeH : CGFloat = 0
        
        if resizeWHScale >= 1 {
            adjustResizeW = self.maxResizeW()
            adjustResizeH = adjustResizeW / resizeWHScale
            if adjustResizeH > self.maxResizeH() {
                adjustResizeH = self.maxResizeH()
                adjustResizeW = self.maxResizeH() * resizeWHScale
            }
        } else {
            adjustResizeH = self.maxResizeH()
            adjustResizeW = adjustResizeH * resizeWHScale
            if adjustResizeW > self.maxResizeW() {
                adjustResizeW = self.maxResizeW()
                adjustResizeH = adjustResizeW / resizeWHScale
            }
        }
        let adjustResizeX = self.maxResizeX() + (self.maxResizeW() - adjustResizeW) * 0.5
        let adjustResizeY = self.maxResizeY() + (self.maxResizeH() - adjustResizeH) * 0.5
        return CGRect.init(x: adjustResizeX, y: adjustResizeY, width: adjustResizeW, height: adjustResizeH)
    }
    
    func scrollViewContentInsetWithAdjustResizeFrame(adjustResizeFrame: CGRect) -> UIEdgeInsets {
        // scrollView宽高跟self一样，上下左右不需要额外添加Space
        let top = adjustResizeFrame.origin.y
        let bottom = self.bounds.size.height - adjustResizeFrame.maxY
        let left = adjustResizeFrame.origin.x
        let right = self.bounds.size.width - adjustResizeFrame.maxX
        return UIEdgeInsets.init(top: top, left: left, bottom: bottom, right: right)
    }
    
    func updateImageResizerFrame(animateDuration duration: TimeInterval) {
        let adjustResizeFrames = adjustResizeFrame()
        let contentInset = scrollViewContentInsetWithAdjustResizeFrame(adjustResizeFrame: adjustResizeFrames)
        
        // contentOffset
        var contentOffset = CGPoint.zero
        let origin = self.imageResizerFrame.origin
        let convertPoint = convert(origin, to: self.imageView)
        
        // 这个convertPoint是相对self.imageView.bounds上的点，所以要✖️zoomScale拿到相对frame实际显示的大小
        contentOffset.x = -contentInset.left + convertPoint.x * self.scrollView.zoomScale
        contentOffset.y = -contentInset.top + convertPoint.y * self.scrollView.zoomScale
        
        let currMinZoomScale : CGFloat  = self.scrollView.minimumZoomScale
        self.scrollView.minimumZoomScale = scrollViewMinZoomScaleWithResizeSize(size: adjustResizeFrames.size)
        var diffMinZoomScale : CGFloat = 1
        if _isRotation && (self.scrollView.zoomScale == currMinZoomScale && self.scrollView.minimumZoomScale != currMinZoomScale) {
            diffMinZoomScale = abs(self.scrollView.minimumZoomScale - currMinZoomScale)
        }
        // zoomFrame
        // 根据裁剪的区域，因为需要有间距，所以拼接成self的尺寸获取缩放的区域zoomFrame
        // 宽高比不变，所以宽度高度的比例是一样，这里就用宽度比例吧
        let convertScale : CGFloat = self.imageResizeW / adjustResizeFrames.size.width
        let diffXSpace : CGFloat = adjustResizeFrames.origin.x * convertScale / diffMinZoomScale
        let diffYSpace : CGFloat = adjustResizeFrames.origin.y * convertScale / diffMinZoomScale
        let convertW : CGFloat = self.imageResizeW + 2 * diffXSpace
        let convertH : CGFloat = self.imageResizeH + 2 * diffYSpace
        let convertX : CGFloat = self.imageResizeX - diffXSpace
        let convertY : CGFloat = self.imageResizeY - diffYSpace
        
        let zoomFrame : CGRect = convert(CGRect.init(x: convertX, y: convertY, width: convertW, height: convertH), to: self.imageView)
        let zoomBlock = {[weak self] in
            guard let self = self else { return }
            self.scrollView.contentInset = contentInset
            self.scrollView.setContentOffset(contentOffset, animated: false)
            self.scrollView.zoom(to: zoomFrame, animated: false)
        }
        let completionBlock = {[weak self] in
            guard let self = self else { return }
            self.superview?.isUserInteractionEnabled = true
            self.checkIsCanRecovery()
            self.isPrepareToScale = false
            self._isRotation = false
        }
        
        self.superview?.isUserInteractionEnabled = false
        self.hideOrShowBlurEffect(isHiden: false, animationDuration: duration)
        self.hideOrShowBorderLine(isHiden: false, animationDuration: duration)
        updateImageResizerFrame(resizerFrame: adjustResizeFrames, animateDuration: duration)
        
        if duration > 0 {
            UIView.animate(withDuration: duration, delay: 0, options: self.animationOption, animations: {
                
                zoomBlock()
            }, completion: {(finished) in
                
                completionBlock()
            })
        }else{
            zoomBlock()
            completionBlock()
        }

    }
    
    func scrollViewMinZoomScaleWithResizeSize(size: CGSize) -> CGFloat {
        var minZoomScale : CGFloat = 1
        let w : CGFloat = size.width
        let h : CGFloat = size.height
        
        if w >= h {
            minZoomScale = w / self.baseImageW
            let imageH = self.baseImageH * minZoomScale
            let trueImageH = h
            if imageH < trueImageH {
                minZoomScale *= (trueImageH / imageH)
            }
            
        } else {
            minZoomScale = h / self.baseImageH
            let imageW = self.baseImageH * minZoomScale
            let trueImageW = w
            if imageW < trueImageW {
                minZoomScale *= (trueImageW / imageW)
            }
        }
        return minZoomScale
    }
    
    func updateMaxResizeFrame(direction : DXImageResizerRotationDirection) {
        var x : CGFloat = 0
        var y : CGFloat = 0
        var w : CGFloat = 0
        var h : CGFloat = 0
        
        if direction == .verticalUp || direction == .verticalDown{
            sizeScale = verSizeScale;
            x = diffHalfW + horBaseMargin;
            y = verBaseMargin;
            w = self.bounds.size.width - 2 * x
            h = self.bounds.size.height - 2 * y
        } else {
            if isRotatedAutoScale {
                sizeScale = horSizeScale;
                x = verBaseMargin / sizeScale
                y = horBaseMargin / sizeScale
                w = self.bounds.size.width - 2 * x
                h = self.bounds.size.height - 2 * y
            } else {
                sizeScale = verSizeScale;
                x = (self.bounds.size.width - contentSize.height) * 0.5 +  verBaseMargin / sizeScale
                y = (self.bounds.size.height - contentSize.width) * 0.5 + horBaseMargin / sizeScale
                w = self.bounds.size.width - 2 * x
                h = self.bounds.size.height - 2 * y
            }
        }
        maxResizeFrame =  CGRect.init(x: x, y: y, width: w, height: h)
        frameLayer!.lineWidth = 1.0 / sizeScale
        var lineW : CGFloat = 0
        if borderStyle == .classic {
            lineW = arrLineW / sizeScale
        }
        
        leftTopDot.lineWidth = lineW;
        leftBottomDot.lineWidth = lineW;
        rightTopDot.lineWidth = lineW;
        rightBottomDot.lineWidth = lineW;
        
        lineW = 0.5 / sizeScale;
        horTopLine.lineWidth = lineW;
        horBottomLine.lineWidth = lineW;
        verLeftLine.lineWidth = lineW;
        verRightLine.lineWidth = lineW;

    }
    
    func checkIsCanRecovery() {
        let isVerticalityMirrors = self.isVerticalityMirror?()  ?? false
        let isHorizontalMirrors = self.isHorizontalMirror?()  ?? false
        if isVerticalityMirrors || isHorizontalMirrors {
            self.isCanRecovery = true
            return
        }
        
        let convertCenter = convert(CGPoint.init(x: self.bounds.midX, y: self.bounds.midY), to: self.imageView)
        let imageViewCenter = CGPoint.init(x: self.imageView.bounds.midX, y: self.imageView.bounds.midY)
        
        let isSameCenter : Bool = labs(Int(convertCenter.x - imageViewCenter.x)) <= 1 && labs(Int(convertCenter.y - imageViewCenter.y)) <= 1
        let isOriginFrame : Bool = rotationDirection == .verticalUp && imageResizerFrameIsEqualImageViewFrame()
        
        self.isCanRecovery = !isOriginFrame || !isSameCenter
    }

    
    func updateRotationDirection(direction: DXImageResizerRotationDirection) {
        updateMaxResizeFrame(direction: rotationDirection)
        if isArbitrarily == false {
            let isVer2Hor = (rotationDirection == .verticalUp || rotationDirection == .verticalDown) && (direction == .horizontalLeft || direction == .horizontalRight)
            let isHor2Ver = (direction == .verticalUp || direction == .verticalDown) && (rotationDirection == .horizontalLeft || rotationDirection == .horizontalRight)
            
            if (isVer2Hor || isHor2Ver) {
                _resizeWHScale = 1.0 / _resizeWHScale
            }
        }
        self.rotationDirection = direction
        
    }
    
    
    
    private func createRGBAColor(color: UIColor) -> DXRGBAColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rInt = Int(r * 255) << 24
        let gInt = Int(g * 255) << 16
        let bInt = Int(b * 255) << 8
        let aInt = Int(a * 255)
        
        let rgba : DXRGBAColor = DXRGBAColor.init(dx_r: CGFloat(rInt), dx_g: CGFloat(gInt), dx_b: CGFloat(bInt), dx_a:CGFloat( aInt))
        return rgba
    }
    
    func addTimer() -> Bool{
        let isHasTimer = removeTimer()
        self.timer = Timer.scheduledTimer(timeInterval: 0.65, target: self, selector: #selector(timerHandle), userInfo: nil, repeats: false)
        RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.common)
        return isHasTimer
    }
    
    @objc func timerHandle() {
         _ = removeTimer()
        updateImageResizerFrame(animateDuration: TimeInterval(self.defaultDuration))
    }
    @discardableResult
    func removeTimer() -> Bool{
        if self.timer != nil {
            timer?.invalidate()
            timer = nil
            return true
        }
        return false
    }

    func hideOrShowBlurEffect(isHiden : Bool, animationDuration duration: TimeInterval) {
        
        if maskType == .normal || isHideBlurEffect == isHiden{
            return
        }
        
        self.isHideBlurEffect = isHiden
        let toOpacity : CGFloat = isHiden ? 0 : 1
        
        if (duration > 0 && self.blurContentView != nil) || (self.blurContentView == nil && imageResizerFrameIsFullImageViewFrame() == false){
            let fromOpacity : CGFloat = isHiden ? 1 : 0
            
            let anim : CABasicAnimation = CABasicAnimation.init(keyPath: "blurEffectView.layer.opacity")
            anim.fillMode = .backwards
            anim.fromValue = fromOpacity
            anim.toValue = toOpacity
            anim.duration = duration
            anim.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName(rawValue: self.kCAMediaTimingFunction!))
            self.blurEffectView.layer.add(anim, forKey: "opacity")
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.blurEffectView.layer.opacity = Float(toOpacity)
            CATransaction.commit()
        }
    }
    
    /// 是否显示边框
    func hideOrShowBorderLine(isHiden : Bool, animationDuration duration: TimeInterval) {
        if borderStyle == .classic || isHideFrameLine == isHiden{
            return
        }
        
        self.isHideFrameLine = isHiden
        let toOpacity : Float = isHiden ? 0 : 1
        
        if duration > 0 {
            let fromOpacity : CGFloat = isHiden ? 1 : 0
            
            let anim : CABasicAnimation = CABasicAnimation.init(keyPath: "opacity")
            anim.fillMode = .backwards
            anim.fromValue = fromOpacity
            anim.toValue = toOpacity
            anim.duration = duration
            anim.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName(rawValue: self.kCAMediaTimingFunction!))
            self.horTopLine.add(anim, forKey: "opacity")
            self.horBottomLine.add(anim, forKey: "opacity")
            self.verLeftLine.add(anim, forKey: "opacity")
            self.verRightLine.add(anim, forKey: "opacity")
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.blurEffectView.layer.opacity = toOpacity
            self.horTopLine.opacity = toOpacity
            self.horBottomLine.opacity = toOpacity
            self.verLeftLine.opacity = toOpacity
            self.verRightLine.opacity = toOpacity
            CATransaction.commit()
        }
    }
    
    func baseImageResizerFrame() ->CGRect {
        if isArbitrarily {
            return self.originImageFrame
        }else{
            var w : CGFloat = 0
            var h : CGFloat = 0
            
            if self.baseImageW >= self.baseImageH {
                h = self.baseImageH
                w = h * _resizeWHScale
                if w > self.maxResizeW() {
                    w = self.maxResizeW()
                    h = w / _resizeWHScale
                }
            }else{
                w = self.baseImageW
                h = w / _resizeWHScale
                if h > self.maxResizeH() {
                    h = self.maxResizeH()
                    w = h / _resizeWHScale
                }
            }
            let x = self.maxResizeX() + (self.maxResizeW() - w) * 0.5
            let y = self.maxResizeY() + (self.maxResizeH() - h) * 0.5
            return CGRect.init(x: x, y: y, width: w, height: h)
        }
    }
}
