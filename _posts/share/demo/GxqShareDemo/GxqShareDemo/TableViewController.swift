//
//  TableViewController.swift
//  GxqShareDemo
//
//  Created by yanghuang on 17/3/28.
//  Copyright © 2017年 com.yang. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    let data = [["title" : "1、语言特性", "segue" : "language"],
                ["title" : "2、storyboard的使用", "segue" : "storyboard"],
                ["title" : "1、语言特性", "segue" : "language"],
                ["title" : "1、语言特性", "segue" : "language"]]
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

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
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "dell")
        }
        
        cell?.textLabel?.text = data[indexPath.row]["title"]
        return cell!
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
}
