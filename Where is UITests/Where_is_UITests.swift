//
//  Where_is_UITests.swift
//  Where is UITests
//
//  Created by Hrytsenko Ruslan on 4/11/20.
//  Copyright © 2020 Ruslan Gritsenko. All rights reserved.
//

import XCTest

class Where_is_UITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testSnapshotGameScreen() throws {
        app.buttons["gear"].tap()
        app.tables.buttons["10"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        snapshot("01GameScreen")
    }
    
    func testSnapshotLevel1Game() throws {
        app.staticTexts["start_label"].tap()
        snapshot("02Level1Game")
    }
    
    func testSnapshotLevel10Game() throws {
        app.buttons["gear"].tap()
        app.tables.staticTexts["10"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.staticTexts["start_label"].tap()
        snapshot("03Level10Game")
    }
    
    func testSnapshotLevelPassed() throws {
        app.buttons["gear"].tap()
        app.tables.staticTexts["9"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.staticTexts["start_label"].tap()
        app.buttons["1_button"].tap()
        snapshot("04LevelPassed")
    }
    
    func testSnapshotSettings() {
        app.buttons["gear"].tap()
        app.tables.staticTexts["10"].tap()
        snapshot("05Settings")
    }
}
