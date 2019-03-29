//
//  ZZAVPlayerTests.swift
//  ZZAVPlayerTests
//
//  Created by zmz on 2019/3/25.
//  Copyright © 2019 zmz. All rights reserved.
//

import XCTest
import AVFoundation

class ZZAVPlayerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let musics = ZZAVPlayerInfo.urlMusics()
        print(musics)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
