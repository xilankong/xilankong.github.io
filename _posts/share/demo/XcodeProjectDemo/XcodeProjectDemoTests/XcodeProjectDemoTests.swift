//
//  XcodeProjectDemoTests.swift
//  XcodeProjectDemoTests
//
//  Created by huang on 17/4/4.
//  Copyright © 2017年 huang.com. All rights reserved.
//

import XCTest
@testable import XcodeProjectDemo

class XcodeProjectDemoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let vc = ViewController()
        assert(vc.AmIHansome())
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
