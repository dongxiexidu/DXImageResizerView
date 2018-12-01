//
//  DXImageResizerConfigure.swift
//  DXImageResizerView
//
//  Created by fashion on 2018/11/28.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit
/// 遮罩样式
public enum DXImageResizerMaskType {
    /// 通常类型，bgColor能任意设置
    case normal
    /// 明亮高斯模糊，bgColor强制为白色，maskAlpha可自行修改，建议为0.3
    case lightBlur
    /// 暗黑高斯模糊，bgColor强制为黑色，maskAlpha可自行修改，建议为0.3
    case darkBlur
}
/// 边框样式
public enum DXImageResizerBorderStyle {
    /// 简洁样式，可拖拽8个方向（固定比例则4个方向）
    case concise
    /// 简洁样式，可拖拽4个方向（4角）
    case conciseWithoutOtherDot
    /// 经典样式，类似微信的裁剪边框样式，可拖拽4个方向
    case classic
}

/// 动画曲线
public enum DXAnimationCurve {
    /// 慢进慢出，中间快
    case easeInOut
    /// 由慢到快
    case easeIn
    /// 由快到慢
    case easeOut
    /// 匀速/线性的
    case linear
}

/// 当前方向
public enum DXImageResizerRotationDirection : Int {
    /// 垂直向上
    case verticalUp = 0
    /// 水平向左
    case horizontalLeft
    /// 垂直向下
    case verticalDown
    /// 水平向右
    case horizontalRight
}

/// 是否可以重置的回调 当裁剪区域缩放至适应范围后就会触发该回调
public typealias DXImageResizerIsCanRecoveryBlock = (Bool)->()

/// 是否预备缩放裁剪区域至适应范围
public typealias DXImageResizerIsPrepareToScaleBlock = (Bool)->Void


class DXImageResizerConfigure: NSObject {
    
    /// 需要裁剪的图片
    var resizeImage : UIImage!
    
    /// 视图区域
    var viewFrame : CGRect = UIScreen.main.bounds
    
    /// 遮罩样式
    var maskType : DXImageResizerMaskType = DXImageResizerMaskType.normal {
        didSet (value){
            if value == .lightBlur {
                self.bgColor = UIColor.white
            }else if value == .darkBlur {
                self.bgColor = UIColor.black
            }
        }
    }
    
    /// 边框样式
    var borderStyle : DXImageResizerBorderStyle = DXImageResizerBorderStyle.concise
    
    /// 动画曲线
    var animationCurve : DXAnimationCurve = DXAnimationCurve.easeOut

    /// 裁剪线颜色
    var strokeColor : UIColor = UIColor.white
    
    /// 背景颜色
    var bgColor : UIColor = UIColor.black{
        didSet (value){
            if self.maskType == .lightBlur {
                bgColor = UIColor.white
            }else if self.maskType == .darkBlur {
                bgColor = UIColor.black
            }else{
                bgColor = value
            }
        }
    }
    
    /// 遮罩颜色的透明度（背景颜色 * 透明度）
    var maskAlpha : CGFloat = 0.75
    
    /// 裁剪宽高比（0则为任意比例，可控8个方向，固定比例为4个方向）
    var resizeWHScale : CGFloat = 0
    
    /// 裁剪图片与裁剪区域的垂直边距
    var verBaseMargin : CGFloat = 10
    
    /// 裁剪图片与裁剪区域的水平边距
    var horBaseMargin : CGFloat = 10
    
    /// 裁剪图片与裁剪区域的水平边距
    var contentInsets : UIEdgeInsets = UIEdgeInsets.zero
    
    /// 是否顺时针旋转
    var isClockwiseRotation : Bool = false
    
    
    public class func defaultConfigure(resizeImage: UIImage, make:(DXImageResizerConfigure)->() ) -> DXImageResizerConfigure{
        let configure = DXImageResizerConfigure.init()
        configure.resizeImage = resizeImage
        make(configure)
        return configure
    }
    public class func blurMaskTypeConfigure(resizeImage: UIImage,isLight : Bool, make:(DXImageResizerConfigure)->() ) -> DXImageResizerConfigure{
        
        let maskType : DXImageResizerMaskType = isLight ? .lightBlur : .darkBlur
        let configure = self.defaultConfigure(resizeImage: resizeImage) { (make) -> () in
            make.dx.maskType(maskType: maskType)
            make.dx.maskAlpha(maskAlpha: 0.3)
        }
        make(configure)
        return configure
    }
    
}


public final class ImageResizeChain<Base> {
    
    public let base : Base
    public init(_ base : Base){
        self.base = base
    }
}

public protocol ImageResizeChainCompatible {
    
}

public extension ImageResizeChainCompatible {
    public var dx : ImageResizeChain<Self> {
        get { return ImageResizeChain(self) }
    }
}

extension DXImageResizerConfigure : ImageResizeChainCompatible {
    
}



extension ImageResizeChain where Base: DXImageResizerConfigure {
    @discardableResult
    func viewFrame(viewFrame : CGRect) -> ImageResizeChain {
        base.viewFrame = viewFrame
        return self
    }
    
    @discardableResult
    func resizeImage(resizeImage : UIImage) -> ImageResizeChain {
        base.resizeImage = resizeImage
        return self
    }
    
    @discardableResult
    func maskType(maskType : DXImageResizerMaskType) -> ImageResizeChain {
        base.maskType = maskType
        return self
    }
    
    @discardableResult
    func borderStyle(borderStyle : DXImageResizerBorderStyle) -> ImageResizeChain {
        base.borderStyle = borderStyle
        return self
    }
    
    
    @discardableResult
    func animationCurve(animationCurve : DXAnimationCurve) -> ImageResizeChain {
        base.animationCurve = animationCurve
        return self
    }
    
    
    @discardableResult
    func strokeColor(strokeColor : UIColor) -> ImageResizeChain {
        base.strokeColor = strokeColor
        return self
    }
    
    @discardableResult
    func bgColor(bgColor : UIColor) -> ImageResizeChain {
        base.bgColor = bgColor
        return self
    }
    
    @discardableResult
    func maskAlpha(maskAlpha : CGFloat) -> ImageResizeChain {
        base.maskAlpha = maskAlpha
        return self
    }
    
    
    @discardableResult
    func resizeWHScale(resizeWHScale : CGFloat) -> ImageResizeChain {
        base.resizeWHScale = resizeWHScale
        return self
    }
    
    @discardableResult
    func horBaseMargin(horBaseMargin : CGFloat) -> ImageResizeChain {
        base.horBaseMargin = horBaseMargin
        return self
    }
    
    @discardableResult
    func contentInsets(contentInsets : UIEdgeInsets) -> ImageResizeChain {
        base.contentInsets = contentInsets
        return self
    }
    
    @discardableResult
    func isClockwiseRotation(isClockwiseRotation : Bool) -> ImageResizeChain {
        base.isClockwiseRotation = isClockwiseRotation
        return self
    }
    
}
