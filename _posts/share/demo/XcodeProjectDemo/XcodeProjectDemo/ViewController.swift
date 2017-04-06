//
//  ViewController.swift
//  XcodeProjectDemo
//
//  Created by huang on 17/4/4.
//  Copyright © 2017年 huang.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var num1: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(type: UIButtonType.custom)
        button.setTitle("按钮", for: UIControlState.normal)
        button.setTitleColor(UIColor.blue, for: UIControlState.normal)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        view.addSubview(button)
        
        button.addTarget(self, action: #selector(buttonAction(btn:)), for: UIControlEvents.touchUpInside)
        
        let imageView = UIImageView(image: UIImage(named: "chat"))
        imageView.frame = CGRect(x: 50, y:100, width: 266, height: 200)
        view.addSubview(imageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buttonAction(btn: UIButton) {
        print("按钮事件")
    }
    
    func AmIHansome() -> Bool {
        return true
    }
}

