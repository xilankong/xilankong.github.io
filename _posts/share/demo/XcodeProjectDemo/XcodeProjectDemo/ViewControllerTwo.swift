//
//  ViewControllerTwo.swift
//  XcodeProjectDemo
//
//  Created by yanghuang on 17/4/6.
//  Copyright © 2017年 huang.com. All rights reserved.
//

import UIKit

class ViewControllerTwo: UIViewController {

    public var style: NSString?
    public var delegate: ViewControllerTwo?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backAction(_ sender: Any) {
        guard let nav = self.navigationController else {
            self.dismiss(animated: true, completion: { 
                
            })
            return
        }
        nav.popViewController(animated: true)
    }
    
    
}
