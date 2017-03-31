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
class baseView: UIView {

    var dateFormatter: DateFormatter?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    //xib storyboard 会调起这个方法
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dateFormatter = DateFormatter()
        dateFormatter?.dateFormat = "HH:mm:ss SSS"
    }

    //MARK: - hitTest 查找
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //"每次touch会调用两次，不知道为啥 "
        //简单来讲，时间戳记录了自从上次开机的时间间隔。它的类型是 NSTimeInterval

        print("进入\(self.classForCoder) hitTest方法")
        let view = super.hitTest(point, with: event)
        print("\n当前View : \(self.classForCoder)\n返回的View : \(view?.classForCoder)\n\(event)\n\(dateFormatter?.string(from: Date()))\n");
        return view
    }
    
    //MARK: - 检查是否在点击范围
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        print("进入\(self.classForCoder) point方法")
        let result = super.point(inside: point, with: event)
        print("是否点击在\(self.classForCoder) 区域范围内 - \(result)")
        return result
    }
    
    //MARK: - 触摸事件开始
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("\(self.classForCoder) touch begin")
        var next = self.next
        var str = "-"
        while next != nil {
            print("\(str) \(next!.classForCoder)")
            next = next?.next
            str = str + "-"
        }
    }
    //MARK: - 触摸事件结束
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("\(self.classForCoder) touch end")
    }
}


class ViewOne: baseView {
}

class ViewTwo: baseView {
}

class ViewThree: baseView {
}



