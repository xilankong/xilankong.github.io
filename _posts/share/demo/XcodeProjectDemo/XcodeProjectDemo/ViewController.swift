//
//  ViewController.swift
//  XcodeProjectDemo
//
//  Created by huang on 17/4/4.
//  Copyright © 2017年 huang.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let image = UIImage(named: "chat")
        let imageView = UIImageView(image: image)
        view.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 50, width: 200, height: 150)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func AmIHansome() -> Bool {
        return true
    }


}

