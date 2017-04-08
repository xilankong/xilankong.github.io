//
//  DynamicBindViewController.swift
//  GxqShareDemo
//  事件绑定
//  Created by yanghuang on 17/3/31.
//  Copyright © 2017年 com.yang. All rights reserved.
//

import UIKit

class DynamicBindViewController: UIViewController {

    @IBOutlet weak var mybutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let XibTestView = Bundle.main.loadNibNamed("XibTestView", owner: nil, options: nil)?[0]
        if let testview = XibTestView as? UIView {
            view.addSubview(testview)
            testview.frame = CGRect(x: 200, y: 500, width: 100, height: 50)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        let alertController = UIAlertController(title: "系统提示",
                                                message: "按钮事件弹窗", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "好的", style: .default, handler: {
            action in
            print("点击了确定")
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

}
