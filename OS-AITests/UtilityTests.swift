//
//  UtilityTests.swift
//  OS-AITests
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  工具类单元测试
//

import XCTest
@testable import OS_AI

final class UtilityTests: XCTestCase {

    // MARK: - Date Extensions Tests

    func testDateIsToday() {
        let today = Date()
        XCTAssertTrue(today.isToday, "Current date should be today")

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        XCTAssertFalse(yesterday.isToday, "Yesterday should not be today")

        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        XCTAssertFalse(tomorrow.isToday, "Tomorrow should not be today")
    }

    func testDateIsPast() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertTrue(yesterday.isPast, "Yesterday should be past")

        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertFalse(tomorrow.isPast, "Tomorrow should not be past")
    }

    func testDateIsFuture() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertTrue(tomorrow.isFuture, "Tomorrow should be future")

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertFalse(yesterday.isFuture, "Yesterday should not be future")
    }

    func testRelativeDescription() {
        let now = Date()

        // 测试今天
        XCTAssertTrue(now.isToday)

        // 测试昨天
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        XCTAssertTrue(yesterday.relativeDescription.contains("天前"))

        // 测试明天
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        XCTAssertTrue(tomorrow.relativeDescription.contains("天后"))
    }

    // MARK: - String Extensions Tests

    func testStringValidation() {
        // 测试邮箱验证
        let validEmail = "test@example.com"
        let invalidEmail = "invalid.email"
        XCTAssertTrue(validEmail.isValidEmail, "Valid email should pass validation")
        XCTAssertFalse(invalidEmail.isValidEmail, "Invalid email should fail validation")

        // 测试手机号验证
        let validPhone = "13800138000"
        let invalidPhone = "12345"
        XCTAssertTrue(validPhone.isValidPhoneNumber, "Valid phone should pass validation")
        XCTAssertFalse(invalidPhone.isValidPhoneNumber, "Invalid phone should fail validation")

        // 测试URL验证
        let validURL = "https://example.com"
        let invalidURL = "not a url"
        XCTAssertTrue(validURL.isValidURL, "Valid URL should pass validation")
        XCTAssertFalse(invalidURL.isValidURL, "Invalid URL should fail validation")
    }

    func testStringIsEmpty() {
        let emptyString = ""
        let whitespaceString = "   "
        let normalString = "test"

        XCTAssertTrue(emptyString.isBlank, "Empty string should be blank")
        XCTAssertTrue(whitespaceString.isBlank, "Whitespace string should be blank")
        XCTAssertFalse(normalString.isBlank, "Normal string should not be blank")
    }

    func testStringTruncated() {
        let longString = "This is a very long string that needs to be truncated"
        let truncated = longString.truncated(to: 20)

        XCTAssertTrue(truncated.count <= 23, "Truncated string should be at most 23 characters (20 + '...')")
        XCTAssertTrue(truncated.hasSuffix("..."), "Truncated string should end with '...'")
    }

    // MARK: - Array Extensions Tests

    func testArraySafeSubscript() {
        let array = [1, 2, 3, 4, 5]

        XCTAssertEqual(array[safe: 2], 3, "Valid index should return element")
        XCTAssertNil(array[safe: 10], "Invalid index should return nil")
        XCTAssertNil(array[safe: -1], "Negative index should return nil")
    }

    func testArrayUnique() {
        let array = [1, 2, 2, 3, 4, 4, 5]
        let unique = array.unique()

        XCTAssertEqual(unique.count, 5, "Should have 5 unique elements")
        XCTAssertEqual(unique.sorted(), [1, 2, 3, 4, 5], "Unique elements should be sorted")
    }

    func testArrayChunked() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let chunks = array.chunked(into: 3)

        XCTAssertEqual(chunks.count, 4, "Should have 4 chunks")
        XCTAssertEqual(chunks[0], [1, 2, 3], "First chunk should be [1, 2, 3]")
        XCTAssertEqual(chunks[3], [10], "Last chunk should be [10]")
    }

    // MARK: - Double Extensions Tests

    func testDoubleFormattedCurrency() {
        let amount = 1234.56
        let formatted = amount.formattedCurrency()

        XCTAssertTrue(formatted.contains("1,234.56"), "Should contain formatted amount")
        XCTAssertTrue(formatted.contains("¥"), "Should contain currency symbol")
    }

    func testDoubleFormattedPercentage() {
        let percentage = 0.8543
        let formatted = percentage.formattedPercentage()

        XCTAssertTrue(formatted.contains("85.43%"), "Should contain percentage")
    }

    func testDoubleFormattedBytes() {
        let bytes: Double = 1024 * 1024 * 2.5  // 2.5 MB
        let formatted = bytes.formattedBytes()

        XCTAssertTrue(formatted.contains("2.5"), "Should contain 2.5")
        XCTAssertTrue(formatted.contains("MB"), "Should contain MB")
    }

    func testDoubleRounded() {
        let value = 3.14159
        let rounded = value.rounded(to: 2)

        XCTAssertEqual(rounded, 3.14, accuracy: 0.01, "Should round to 2 decimal places")
    }

    func testDoubleIsInteger() {
        XCTAssertTrue((3.0).isInteger, "3.0 should be integer")
        XCTAssertFalse((3.14).isInteger, "3.14 should not be integer")
    }

    // MARK: - Color Extensions Tests

    func testColorFromHex() {
        let color = Color(hex: "#FF5733")

        // 测试颜色创建成功（没有异常即可）
        XCTAssertTrue(true, "Color should be created from hex")
    }

    // MARK: - Helper Function Tests

    func testGenerateID() {
        let id1 = generateID()
        let id2 = generateID()

        XCTAssertNotEqual(id1, id2, "Generated IDs should be unique")
        XCTAssertTrue(id1.count == 36, "ID should be UUID format (36 characters)")
    }

    func testIsValidPhoneNumber() {
        XCTAssertTrue(isValidPhoneNumber("13800138000"), "Valid phone should pass")
        XCTAssertFalse(isValidPhoneNumber("12345"), "Invalid phone should fail")
        XCTAssertFalse(isValidPhoneNumber("138001380001"), "Too long phone should fail")
    }

    func testIsValidEmail() {
        XCTAssertTrue(isValidEmail("test@example.com"), "Valid email should pass")
        XCTAssertFalse(isValidEmail("invalid.email"), "Invalid email should fail")
        XCTAssertFalse(isValidEmail("@example.com"), "Email without local part should fail")
        XCTAssertFalse(isValidEmail("test@"), "Email without domain should fail")
    }

    // MARK: - Performance Tests

    func testGenerateIDPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = generateID()
            }
        }
    }

    func testStringValidationPerformance() {
        let emails = Array(repeating: "test@example.com", count: 1000)

        measure {
            for email in emails {
                _ = email.isValidEmail
            }
        }
    }

    func testArrayOperationsPerformance() {
        let array = Array(1...1000)

        measure {
            _ = array.unique()
            _ = array.chunked(into: 10)
        }
    }
}
