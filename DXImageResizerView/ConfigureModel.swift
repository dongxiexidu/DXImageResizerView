//
//  ConfigureModel.swift
//  DXImageResizerView
//
//  Created by fashion on 2018/12/1.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class ConfigureModel: NSObject {
    
    var title : String
    var configure : DXImageResizerConfigure
    
    init(title :String,configure : DXImageResizerConfigure) {
        self.title = title
        self.configure = configure
    }

}
