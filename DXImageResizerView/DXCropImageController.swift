//
//  DXCropImageController.swift
//  DXImageResizerView
//
//  Created by fashion on 2018/12/1.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class DXCropImageController: UIViewController {
    
    var configure : DXImageResizerConfigure!
    
    @IBOutlet weak var recoveryBtn: UIButton!
    @IBOutlet weak var goBackBtn: UIButton!
    @IBOutlet weak var horMirrorBtn: UIButton!
    @IBOutlet weak var verMirrorBtn: UIButton!
    @IBOutlet weak var rotateBtn: UIButton!
    @IBOutlet weak var resizeBtn: UIButton!
    
    var imageResizerView : DXImageResizerView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = self.configure.bgColor
        self.recoveryBtn.isEnabled = false
        
        let imgResizerView = DXImageResizerView.imageResizerView(configure: configure, imageResizerIsCanRecovery: {[weak self] (isCanRecovery) in
            guard let self = self else{ return }
            self.recoveryBtn.isEnabled = isCanRecovery
        }, imageResizerIsPrepareToScale: {[weak self] (isPrepareToScale) in
            guard let self = self else{ return }
            let isEabled = !isPrepareToScale
            self.rotateBtn.isEnabled = isEabled
            self.resizeBtn.isEnabled = isEabled
            self.horMirrorBtn.isEnabled = isEabled
            self.verMirrorBtn.isEnabled = isEabled
        })
        
        self.view.insertSubview(imgResizerView, at: 0)
        self.imageResizerView = imgResizerView
        self.configure = nil
        
    }
    
    deinit {
        printLog("DXCropImageController -- deinit")
    }
    
    
    @IBAction func changeBorderStyle(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        var borderStyles : DXImageResizerBorderStyle!
        
        if sender.isSelected {
            borderStyles = .classic
        }else{
            borderStyles = .concise
        }
        imageResizerView.borderStyle = borderStyles
    }
    
    @IBAction func rotate(_ sender: Any) {
        imageResizerView.rotation()
    }
    
    @IBAction func recovery(_ sender: Any) {
        imageResizerView.recovery()
    }
    
    @IBAction func anyScale(_ sender: Any) {
        imageResizerView.resizeWHScale = 0
    }
    
    @IBAction func one2one(_ sender: Any) {
        imageResizerView.resizeWHScale = 1
    }
    
    @IBAction func sixteen2nine(_ sender: Any) {
        imageResizerView.resizeWHScale = 16.0 / 9.0
    }
    
    @IBAction func replaceImage(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        var image : UIImage!
        if sender.isSelected {
            image = UIImage.init(named: "Lotus.jpg")
        } else {
            image = UIImage.init(named: "Girl.jpg")
        }
        imageResizerView.resizeImage = image
    }
    
    @IBAction func resize(_ sender: Any) {
        self.recoveryBtn.isEnabled = false
        
        // 1.默认以imageView的宽度为参照宽度进行裁剪
        imageResizerView.imageResizer {[weak self] (resizeImage) in
            guard let self = self else{ return }
            guard let image = resizeImage else{ return }

            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DXImageViewController") as! DXImageViewController
            vc.image = image
            self.navigationController?.pushViewController(vc, animated: true)
            self.recoveryBtn.isEnabled = true
        }
        
        // 2.自定义参照宽度进行裁剪（例如按屏幕宽度）
//        imageResizerView.imageResizer(completion: {[weak self] (resizeImage) in
//            guard let self = self else{ return }
//            guard let image = resizeImage else{ return }
//
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DXImageViewController") as! DXImageViewController
//            vc.image = image
//            self.navigationController?.pushViewController(vc, animated: true)
//            self.recoveryBtn.isEnabled = true
//        }, referenceWidth: UIScreen.main.bounds.size.width)
        
        
        // 3.以原图尺寸进行裁剪
//        imageResizerView.originImageResizer { [weak self] (resizeImage) in
//            guard let self = self else{ return }
//            guard let image = resizeImage else{ return }
//
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DXImageViewController") as! DXImageViewController
//            vc.image = image
//            self.navigationController?.pushViewController(vc, animated: true)
//            self.recoveryBtn.isEnabled = true
//        }
        
        
    }
    
    // ================
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func lockFrame(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.imageResizerView.isLockResizeFrame = sender.isSelected
    }
    
    @IBAction func horizontalMirror(_ sender: Any) {
        self.imageResizerView.setHorizontalMirror(horizontalMirror: !self.imageResizerView.horizontalMirror, animated: true)
    }
    
    @IBAction func verticalMirror(_ sender: Any) {
        self.imageResizerView.setVerticalityMirror(verticalMirror: !self.imageResizerView.verticalityMirror, animated: true)
    }
}
