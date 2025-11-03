//
//  NetworkManagerTests.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Testing
import Foundation
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

// MARK: - NetworkManager Tests

@Suite("NetworkManager Tests", .serialized)
struct NetworkManagerTests {

    let sut: NetworkManager

    init() {
        // Configure URLSession with MockURLProtocol
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        self.sut = NetworkManager(baseURL: "https://api.test.com")
        MockURLProtocol.reset()
    }

    // MARK: - Success Tests

    @Test("Fetch successful single object response")
    func fetchSuccessfulResponse() async throws {
        // Given
        let endpoint = "/api/test"
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let group = try TestDataFactory.groupInfo().build()
        let encoder = JSONEncoder()
        let json = try encoder.encode(group)

        MockURLProtocol.setMockResponse(url: url, data: json, statusCode: 200)

        // When
        let result: GroupInfo = try await sut.fetch(endpoint: endpoint)

        // Then
        #expect(result.groupId == group.groupId)
        #expect(result.code == group.code)
    }

    @Test("Fetch successful array response")
    func fetchSuccessfulArrayResponse() async throws {
        // Given
        let endpoint = "/api/groups"
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let groups = [
            try TestDataFactory.groupInfo().with(groupId: 1).build(),
            try TestDataFactory.groupInfo().with(groupId: 2).build()
        ]
        let encoder = JSONEncoder()
        let json = try encoder.encode(groups)

        MockURLProtocol.setMockResponse(url: url, data: json, statusCode: 200)

        // When
        let result: [GroupInfo] = try await sut.fetch(endpoint: endpoint)

        // Then
        #expect(result.count == 2)
        #expect(result[0].groupId == 1)
        #expect(result[1].groupId == 2)
    }

    @Test("Fetch with empty array response")
    func fetchEmptyArrayResponse() async throws {
        // Given
        let endpoint = "/api/groups"
        let url = URL(string: "https://api.test.com\(endpoint)")!
        let emptyArray = "[]".data(using: .utf8)!

        MockURLProtocol.setMockResponse(url: url, data: emptyArray, statusCode: 200)

        // When
        let result: [GroupInfo] = try await sut.fetch(endpoint: endpoint)

        // Then
        #expect(result.isEmpty)
    }

    // MARK: - Error Tests

    @Test("Fetch throws invalidURL error for invalid endpoint")
    func fetchInvalidURL() async {
        // Given
        let endpoint = "not a valid endpoint with spaces"

        // When & Then
        await #expect(throws: NetworkError.self) {
            let _: GroupInfo = try await sut.fetch(endpoint: endpoint)
        }
    }

    @Test("Fetch HTTP errors", arguments: [
        (404, "Not Found"),
        (500, "Server Error"),
        (401, "Unauthorized"),
        (403, "Forbidden")
    ])
    func fetchHTTPError(statusCode: Int, description: String) async throws {
        // Given
        let endpoint = "/api/error"
        let url = URL(string: "https://api.test.com\(endpoint)")!
        let errorJSON = """
        {"error": "\(description)"}
        """.data(using: .utf8)!

        MockURLProtocol.setMockResponse(url: url, data: errorJSON, statusCode: statusCode)

        // When & Then
        do {
            let _: GroupInfo = try await sut.fetch(endpoint: endpoint)
            Issue.record("Should throw HTTP error")
        } catch let error as NetworkError {
            switch error {
            case .httpError(let code):
                #expect(code == statusCode)
            default:
                Issue.record("Expected httpError, got \(error)")
            }
        }
    }

    @Test("Fetch throws error for invalid JSON")
    func fetchInvalidJSON() async throws {
        // Given
        let endpoint = "/api/test"
        let url = URL(string: "https://api.test.com\(endpoint)")!
        let invalidJSON = "not a valid json".data(using: .utf8)!

        MockURLProtocol.setMockResponse(url: url, data: invalidJSON, statusCode: 200)

        // When & Then
        await #expect(throws: Error.self) {
            let _: GroupInfo = try await sut.fetch(endpoint: endpoint)
        }
    }

    // MARK: - Success Status Codes

    @Test("Fetch handles 2xx status codes", arguments: [200, 201, 202, 299])
    func fetchSuccessStatusCodes(statusCode: Int) async throws {
        // Given
        let endpoint = "/api/test"
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let group = try TestDataFactory.groupInfo().build()
        let encoder = JSONEncoder()
        let json = try encoder.encode(group)

        MockURLProtocol.setMockResponse(url: url, data: json, statusCode: statusCode)

        // When
        let result: GroupInfo = try await sut.fetch(endpoint: endpoint)

        // Then
        #expect(result.groupId == group.groupId)
    }

    // MARK: - Endpoint Formatting

    @Test("Fetch with various endpoint formats", arguments: [
        "/api/test",
        "/api/test?param=value",
        "/api/test?param=value&other=123"
    ])
    func fetchEndpointFormats(endpoint: String) async throws {
        // Given
        let url = URL(string: "https://api.test.com\(endpoint)")!

        let group = try TestDataFactory.groupInfo().build()
        let encoder = JSONEncoder()
        let json = try encoder.encode(group)

        MockURLProtocol.setMockResponse(url: url, data: json, statusCode: 200)

        // When
        let result: GroupInfo = try await sut.fetch(endpoint: endpoint)

        // Then
        #expect(result.groupId == group.groupId)
    }
}
