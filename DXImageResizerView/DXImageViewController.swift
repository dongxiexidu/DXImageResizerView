//
//  DXImageViewController.swift
//  DXImageResizerView
//
//  Created by fashion on 2018/12/1.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class DXImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var image :UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = self.image
    }
    
}
