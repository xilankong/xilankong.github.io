//
//  ViewController.swift
//  GxqShareDemo
//
//  Created by yanghuang on 17/3/28.
//  Copyright © 2017年 com.yang. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController {
    @IBOutlet weak var sendLabel: UILabel!

    @IBOutlet weak var getLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? LanguageViewControllerTwo,
                segue.identifier == "languageTwo" else {
            return
        }
        vc.msgFromXB = sendLabel.text
        vc.callbackClosure = {[weak self] (callbackMsg: String) in
            self?.getLabel.text = callbackMsg
        }
    }
}

