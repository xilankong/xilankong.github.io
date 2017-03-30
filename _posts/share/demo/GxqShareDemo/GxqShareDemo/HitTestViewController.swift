//
//  HitTestViewController.swift
//  GxqShareDemo
//
//  Created by yanghuang on 17/3/30.
//  Copyright © 2017年 com.yang. All rights reserved.
//

import UIKit

class HitTestViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
}


class ViewOne: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //"每次touch会调用两次，不知道为啥 "
        //简单来讲，时间戳记录了自从上次开机的时间间隔。它的类型是 NSTimeInterval
        let view = super.hitTest(point, with: event)
        print("当前View : \(self.classForCoder) - \(view?.classForCoder)   \(event) - \(Date())");
        return view
    }
}

class ViewTwo: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        print("当前View : \(self.classForCoder) - \(view?.classForCoder)   \(event) - \(Date())");
        return view
    }
}

class ViewThree: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        print("当前View : \(self.classForCoder) - \(view?.classForCoder)   \(event) - \(Date())");
        return view
    }
}



