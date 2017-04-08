//
//  LifeCycleViewController.swift
//  GxqShareDemo
//  控制器生命周期
//  Created by yanghuang on 17/3/31.
//  Copyright © 2017年 com.yang. All rights reserved.
//

import UIKit

class LifeCycleViewController: UIViewController {

    fileprivate  var timer: Timer?
    override func loadView() {
        //print(self.view) 不能出现self.view的调用
        //如果在super之前调用self.view 又会回来调用loadView 就会出现死循环
        
        super.loadView()
        //这个方法主要创建self.view,一般情况下不覆写，除非需要重新View
        //它会先去查找与LifeCycleViewController相关联的xib文件，没有的时候，创建空View。
        print("[生命周期] \(self.classForCoder) loadView 加载基础控制器 nib")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[生命周期] \(self.classForCoder) viewDidLoad 创建视图")
        
//        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(writing), userInfo: nil, repeats: true)
        
    }
    
    func writing() {
        print("我还在循环")
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
        print("[生命周期] \(self.classForCoder) viewWillDisappear 视图即将消失")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("[生命周期] \(self.classForCoder) viewDidDisappear 视图完全消失")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    deinit {
        print("[生命周期] \(self.classForCoder) deinit 视图销毁")
    }

}
