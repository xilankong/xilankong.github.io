//
//  TableViewController.swift
//  GxqShareDemo
//  首页列表
//  Created by yanghuang on 17/3/28.
//  Copyright © 2017年 com.yang. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    //MARK: - dataSource数据源
    let data = [["title" : "1、语言特性", "segue" : "language"],
                ["title" : "2、Storyboard/UI控件", "segue" : "storyboard"],
                ["title" : "3、生命周期", "segue" : "lifecycle"],
                ["title" : "4、事件响应链", "segue" : "hitTest"]]
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - tableView 协议方法实现

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let segue = data[indexPath.row]["segue"] else {
            return
        }
        self.performSegue(withIdentifier: segue, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
            UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = data[indexPath.row]["title"]
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
}
