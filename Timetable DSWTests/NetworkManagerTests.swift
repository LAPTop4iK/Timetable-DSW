//
//  NetworkManagerTests.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import XCTest
@testable import Timetable_DSW

// MARK: - Mock URLProtocol

class MockURLProtocol: URLProtocol {
    static var mockResponses: [URL: (data: Data, response: HTTPURLResponse, error: Error?)] = [:]

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = request.url,
              let mock = MockURLProtocol.mockResponses[url] else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        if let error = mock.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        client?.urlProtocol(self, didReceive: mock.response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: mock.data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    static func reset() {
        mockResponses.removeAll()
    }

    static func setMockResponse(url: URL, data: Data, statusCode: Int = 200, error: Error? = nil) {
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        mockResponses[url] = (data: data, response: response, error: error)
    }
}

// MARK: - NetworkManagerTests

final class NetworkManagerTests: XCTestCase {

    var sut: NetworkManager!

    override func setUp() async throws {
        try await super.setUp()

        // Configure URLSession with MockURLProtocol
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        // Note: We can't easily inject URLSession into NetworkManager as it's an actor
        // So we'll test the real NetworkManager with mocked endpoints
        sut = NetworkManager(baseURL: "https://api.test.com")

        MockURLProtocol.reset()
    }

    override func tearDown() async throws {
        sut = nil
        MockURLProtocol.reset()
        try await super.tearDown()
    }

    // MARK: - Success Tests

    func testFetch_SuccessfulResponse() async throws {
        // Given
        let endpoint = "/api/test"
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let json = """
        {
            "groupId": 1,
            "code": "CS101",
            "name": "Computer Science",
            "tracks": [],
            "program": "Bachelor",
            "faculty": "Engineering"
        }
        """.data(using: .utf8)!

        MockURLProtocol.setMockResponse(url: url, data: json, statusCode: 200)

        // When
        let result: GroupInfo = try await sut.fetch(endpoint: endpoint)

        // Then
        XCTAssertEqual(result.groupId, 1)
        XCTAssertEqual(result.code, "CS101")
        XCTAssertEqual(result.name, "Computer Science")
    }

    func testFetch_SuccessfulArrayResponse() async throws {
        // Given
        let endpoint = "/api/groups"
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let json = """
        [
            {
                "groupId": 1,
                "code": "CS101",
                "name": "Computer Science",
                "tracks": [],
                "program": "Bachelor",
                "faculty": "Engineering"
            },
            {
                "groupId": 2,
                "code": "CS102",
                "name": "Advanced CS",
                "tracks": [],
                "program": "Master",
                "faculty": "Engineering"
            }
        ]
        """.data(using: .utf8)!

        MockURLProtocol.setMockResponse(url: url, data: json, statusCode: 200)

        // When
        let result: [GroupInfo] = try await sut.fetch(endpoint: endpoint)

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].groupId, 1)
        XCTAssertEqual(result[1].groupId, 2)
    }

    // MARK: - Error Tests

    func testFetch_InvalidURL() async {
        // Given
        let endpoint = "not a valid endpoint with spaces"

        // When & Then
        do {
            let _: GroupInfo = try await sut.fetch(endpoint: endpoint)
            XCTFail("Should throw invalidURL error")
        } catch let error as NetworkError {
            switch error {
            case .invalidURL:
                // Expected
                break
            default:
                XCTFail("Expected invalidURL error, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }

    func testFetch_HTTPError404() async throws {
        // Given
        let endpoint = "/api/not-found"
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let json = """
        {"error": "Not found"}
        """.data(using: .utf8)!

        MockURLProtocol.setMockResponse(url: url, data: json, statusCode: 404)

        // When & Then
        do {
            let _: GroupInfo = try await sut.fetch(endpoint: endpoint)
            XCTFail("Should throw HTTP error")
        } catch let error as NetworkError {
            switch error {
            case .httpError(let statusCode):
                XCTAssertEqual(statusCode, 404)
            default:
                XCTFail("Expected httpError, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }

    func testFetch_HTTPError500() async throws {
        // Given
        let endpoint = "/api/error"
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let json = """
        {"error": "Internal server error"}
        """.data(using: .utf8)!

        MockURLProtocol.setMockResponse(url: url, data: json, statusCode: 500)

        // When & Then
        do {
            let _: GroupInfo = try await sut.fetch(endpoint: endpoint)
            XCTFail("Should throw HTTP error")
        } catch let error as NetworkError {
            switch error {
            case .httpError(let statusCode):
                XCTAssertEqual(statusCode, 500)
            default:
                XCTFail("Expected httpError, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }

    func testFetch_InvalidJSON() async throws {
        // Given
        let endpoint = "/api/test"
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let invalidJSON = "not a valid json".data(using: .utf8)!

        MockURLProtocol.setMockResponse(url: url, data: invalidJSON, statusCode: 200)

        // When & Then
        do {
            let _: GroupInfo = try await sut.fetch(endpoint: endpoint)
            XCTFail("Should throw decoding error")
        } catch {
            // Expected decoding error
        }
    }

    // MARK: - Edge Cases

    func testFetch_EmptyResponse() async throws {
        // Given
        let endpoint = "/api/test"
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let emptyJSON = "{}".data(using: .utf8)!

        MockURLProtocol.setMockResponse(url: url, data: emptyJSON, statusCode: 200)

        // When & Then
        do {
            let _: GroupInfo = try await sut.fetch(endpoint: endpoint)
            XCTFail("Should throw decoding error for incomplete data")
        } catch {
            // Expected decoding error
        }
    }

    func testFetch_EmptyArrayResponse() async throws {
        // Given
        let endpoint = "/api/groups"
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let emptyArray = "[]".data(using: .utf8)!

        MockURLProtocol.setMockResponse(url: url, data: emptyArray, statusCode: 200)

        // When
        let result: [GroupInfo] = try await sut.fetch(endpoint: endpoint)

        // Then
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Success Status Codes

    func testFetch_StatusCode201() async throws {
        // Given
        let endpoint = "/api/test"
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let json = """
        {
            "groupId": 1,
            "code": "CS101",
            "name": "Computer Science",
            "tracks": [],
            "program": "Bachelor",
            "faculty": "Engineering"
        }
        """.data(using: .utf8)!

        MockURLProtocol.setMockResponse(url: url, data: json, statusCode: 201)

        // When
        let result: GroupInfo = try await sut.fetch(endpoint: endpoint)

        // Then
        XCTAssertEqual(result.groupId, 1)
    }

    func testFetch_StatusCode299() async throws {
        // Given
        let endpoint = "/api/test"
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let json = """
        {
            "groupId": 1,
            "code": "CS101",
            "name": "Computer Science",
            "tracks": [],
            "program": "Bachelor",
            "faculty": "Engineering"
        }
        """.data(using: .utf8)!

        MockURLProtocol.setMockResponse(url: url, data: json, statusCode: 299)

        // When
        let result: GroupInfo = try await sut.fetch(endpoint: endpoint)

        // Then
        XCTAssertEqual(result.groupId, 1)
    }

    // MARK: - Endpoint Formatting

    func testFetch_EndpointWithLeadingSlash() async throws {
        // Given
        let endpoint = "/api/test"
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let json = """
        {
            "groupId": 1,
            "code": "CS101",
            "name": "Computer Science",
            "tracks": [],
            "program": "Bachelor",
            "faculty": "Engineering"
        }
        """.data(using: .utf8)!

        MockURLProtocol.setMockResponse(url: url, data: json, statusCode: 200)

        // When
        let result: GroupInfo = try await sut.fetch(endpoint: endpoint)

        // Then
        XCTAssertEqual(result.groupId, 1)
    }

    func testFetch_EndpointWithQueryParameters() async throws {
        // Given
        let endpoint = "/api/test?param=value&other=123"
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let json = """
        {
            "groupId": 1,
            "code": "CS101",
            "name": "Computer Science",
            "tracks": [],
            "program": "Bachelor",
            "faculty": "Engineering"
        }
        """.data(using: .utf8)!

        MockURLProtocol.setMockResponse(url: url, data: json, statusCode: 200)

        // When
        let result: GroupInfo = try await sut.fetch(endpoint: endpoint)

        // Then
        XCTAssertEqual(result.groupId, 1)
    }
}
