//
//  AppDelegate.swift
//  GxqShareDemo
//
//  Created by yanghuang on 17/3/28.
//  Copyright © 2017年 com.yang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        /**
         启动时调用
         **/
        // Override point for customization after application launch.
        print("[生命周期] \(self.classForCoder) - App启动")
        
        self.makeException()
//        try! self.throwException()
        if let exceptionMsg = try? self.throwException() {
            print("可选值非空: \(exceptionMsg)")
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        /**
         当有电话进来或者锁屏，这时你的应用程会挂起，在这时，调用applicationWillResignActive 方法。
         你可以重写这个方法，做挂起前的工作，比如关闭网络，保存数据。
        **/
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        /** 
         进入后台后调用
         **/
        print("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        /**
         将要从后台唤起调用
         **/
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        /**
         启动时、唤起后调用
         **/
        print("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        /**
         当一个程序将要正常终止时会调用 applicationWillTerminate方法。
         但是如果长主按钮强制退出，则不会调用该方法。
         这个方法该执行剩下的清理工作，比如所有的连接都能正常关闭，并在程序退出前执行任何其他的必要的工作
         **/
        print("applicationWillTerminate")
    }

    enum myError: Error {
        case testError
    }
    
    func makeException() {
        do {
            //延迟处理
            defer {
                print("异常已抛出")
            }
            throw myError.testError
        } catch {
            print(error)
        }
    }
    
    func throwException() throws {
        throw myError.testError
    }
}

