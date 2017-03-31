//
//  LifeCycleViewController.swift
//  GxqShareDemo
//
//  Created by yanghuang on 17/3/31.
//  Copyright © 2017年 com.yang. All rights reserved.
//

import UIKit

class LifeCycleViewController: UIViewController {

    override func loadView() {
//        super.loadView()
        //从同名xib载入视图,如果同名xib没有的时候。一般情况下不用用到，除非需要重写设置View
        print("[生命周期] \(self.classForCoder) loadView 加载View")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[生命周期] \(self.classForCoder) viewDidLoad 创建视图")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("[生命周期] \(self.classForCoder) viewWillAppear 视图即将呈现")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("[生命周期] \(self.classForCoder) viewDidAppear 视图完全呈现")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("[生命周期] \(self.classForCoder) viewWillAppear 视图即将消失")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("[生命周期] \(self.classForCoder) viewWillAppear 视图完全消失")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    
    deinit {
        print("[生命周期] \(self.classForCoder) 销毁")
    }

}
