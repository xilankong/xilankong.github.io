//
//  LanguageViewControllerTwo.swift
//  GxqShareDemo
//
//  Created by yanghuang on 17/4/6.
//  Copyright © 2017年 com.yang. All rights reserved.
//

import UIKit

class LanguageViewControllerTwo: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var getLabel: UILabel!
    public var msgFromXB: String?
    public var callbackClosure: ((_ msg: String) -> Void)?
    
    //MARK: - 控制器View加载完成
    override func viewDidLoad() {
        super.viewDidLoad()
        getLabel.text = msgFromXB ?? ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - 回复按钮事件
    @IBAction func backAction(_ sender: Any) {
        guard let callbackClosure = self.callbackClosure,
                    let text = self.textField.text else {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }

        callbackClosure(text == "" ? "噢，小明不想理小白" : text)
        _ = self.navigationController?.popViewController(animated: true)
        
    }

}
