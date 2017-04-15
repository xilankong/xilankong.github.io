//
//  ViewController.swift
//  GxqShareDemo
//  闭包、delegate特性
//  Created by yanghuang on 17/3/28.
//  Copyright © 2017年 com.yang. All rights reserved.
//

import UIKit

protocol CallbackProtocol: class {
    func callBackFunc(callbackMsg: String)
}

class LanguageViewController: UIViewController, CallbackProtocol {
    
    @IBOutlet weak var sendLabel: UILabel!
    @IBOutlet weak var getLabel: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    //MARK: - 初始化View完成
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //segue转场拦截
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? LanguageViewControllerTwo,
                segue.identifier == "languageTwo" else {
            return
        }
        vc.msgFromXB = sendLabel.text
        
        //闭包 回调
        vc.callbackClosure = { [weak self] (callbackMsg: String) in
            self?.getLabel.text = callbackMsg
        }
        vc.delegate = self
    }
    
    //代理callback方法
    internal func callBackFunc(callbackMsg: String) {
        self.getLabel.text = callbackMsg
    }
    

}

