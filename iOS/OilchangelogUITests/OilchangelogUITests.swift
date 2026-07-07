import XCTest

final class OilchangelogUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAddEntryFlow() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText("UI Test Entry")
        app.buttons["saveButton"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 5))
    }

    func testFreeLimitTriggersPaywall() throws {
        let app = XCUIApplication()
        app.launch()
        for i in 0..<20 {
            app.buttons["addButton"].tap()
            if app.buttons["purchaseButton"].waitForExistence(timeout: 2) {
                break
            }
            let titleField = app.textFields["titleField"]
            if titleField.waitForExistence(timeout: 2) {
                titleField.tap()
                titleField.typeText("Entry \(i)")
                app.buttons["saveButton"].tap()
            }
        }
        XCTAssertTrue(app.buttons["purchaseButton"].waitForExistence(timeout: 5))
    }

    func testKeyboardDismissOnTapOutside() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText("Dismiss Test")
        XCTAssertTrue(app.keyboards.element.exists)
        app.staticTexts["Date"].tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testCancelDismissesForm() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addButton"].tap()
        XCTAssertTrue(app.buttons["cancelButton"].waitForExistence(timeout: 5))
        app.buttons["cancelButton"].tap()
        XCTAssertTrue(app.buttons["addButton"].waitForExistence(timeout: 5))
    }
}
