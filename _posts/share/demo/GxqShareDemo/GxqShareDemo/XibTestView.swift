//
//  XibTestView.swift
//  GxqShareDemo
//
//  Created by yanghuang on 17/3/31.
//  Copyright © 2017年 com.yang. All rights reserved.
//

import UIKit

class XibTestView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("\(self.classForCoder) 初始化")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        print("\(self.classForCoder) 初始化")
    }
}
