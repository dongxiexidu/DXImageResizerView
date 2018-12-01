//
//  TDXableViewController.swift
//  DXImageResizerView
//
//  Created by fashion on 2018/12/1.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class TDXableViewController: UITableViewController {
    
    var configures : [ConfigureModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Example"
        let image = UIImage.init(named: "Girl.jpg")
        let contentInsets : UIEdgeInsets = .init(top: 50, left: 0, bottom: (40 + 30 + 30 + 10), right: 0)
        let title1 = "默认样式"
        let configure1 = DXImageResizerConfigure.defaultConfigure(resizeImage: image!) { (configure) in
            configure.dx.contentInsets(contentInsets: contentInsets)
        }
        
        let title2 = "深色毛玻璃遮罩"
        let configure2 = DXImageResizerConfigure.blurMaskTypeConfigure(resizeImage: image!, isLight: false) { (configure) in
            configure.dx
                .contentInsets(contentInsets: contentInsets)
                .strokeColor(strokeColor: UIColor.red)
        }
        
        let title3 = "浅色毛玻璃遮罩"
        let configure3 = DXImageResizerConfigure.blurMaskTypeConfigure(resizeImage: image!, isLight: true) { (configure) in
            configure.dx
                .contentInsets(contentInsets: contentInsets)
                .strokeColor(strokeColor: UIColor.blue)
                .resizeImage(resizeImage: UIImage.init(named: "Lotus.jpg")!)
            
        }
        
        let title4 = "其他样式"
        let configure4 = DXImageResizerConfigure.defaultConfigure(resizeImage: image!) { (configure) in
            configure.dx
                .contentInsets(contentInsets: contentInsets)
                .resizeImage(resizeImage: UIImage.init(named: "Kobe.jpg")!)
                .strokeColor(strokeColor: UIColor.yellow)
                .borderStyle(borderStyle: .classic)
                .maskAlpha(maskAlpha: 0.5)
                .bgColor(bgColor: UIColor.orange)
                .isClockwiseRotation(isClockwiseRotation: true)
                .animationCurve(animationCurve: .easeOut)
        }
        
        let model1 = ConfigureModel.init(title: title1, configure: configure1)
        let model2 = ConfigureModel.init(title: title2, configure: configure2)
        let model3 = ConfigureModel.init(title: title3, configure: configure3)
        let model4 = ConfigureModel.init(title: title4, configure: configure4)
        self.configures.append(model1)
        self.configures.append(model2)
        self.configures.append(model3)
        self.configures.append(model4)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }
}


extension TDXableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.configures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let configure = self.configures[indexPath.row]
        cell.textLabel?.text = configure.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DXCropImageController") as! DXCropImageController
        let model = self.configures[indexPath.row]
        vc.configure = model.configure
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
