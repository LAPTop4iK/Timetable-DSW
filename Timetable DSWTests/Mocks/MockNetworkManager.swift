//
//  MockNetworkManager.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Foundation
@testable import Timetable_DSW

// MARK: - Mock Network Manager

/// Mock implementation of NetworkManager for testing
/// Supports custom responses, delays, and error injection
@MainActor
final class MockNetworkManager: NetworkManagerProtocol {

    // MARK: - Configuration

    struct Configuration {
        var shouldDelay: Bool = false
        var delayDuration: TimeInterval = 0.1
        var shouldFail: Bool = false
        var failureError: Error = NetworkError.invalidResponse
    }

    // MARK: - Properties

    private(set) var fetchCallCount: Int = 0
    private(set) var lastFetchedEndpoint: String?
    private var configuration: Configuration
    private var mockedResponses: [String: Any] = [:]

    // MARK: - Initialization

    init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }

    // MARK: - Public Methods

    func fetch<T: Decodable>(endpoint: String) async throws -> T {
        fetchCallCount += 1
        lastFetchedEndpoint = endpoint

        // Simulate network delay
        if configuration.shouldDelay {
            try await Task.sleep(nanoseconds: UInt64(configuration.delayDuration * 1_000_000_000))
        }

        // Simulate failure
        if configuration.shouldFail {
            throw configuration.failureError
        }

        // Return mocked response
        guard let response = mockedResponses[endpoint] else {
            throw NetworkError.invalidResponse
        }

        guard let typedResponse = response as? T else {
            throw NetworkError.invalidResponse
        }

        return typedResponse
    }

    // MARK: - Test Configuration Methods

    func setMockResponse<T: Encodable>(_ response: T, forEndpoint endpoint: String) {
        mockedResponses[endpoint] = response
    }

    func setConfiguration(_ config: Configuration) {
        configuration = config
    }

    func setShouldFail(_ shouldFail: Bool, error: Error = NetworkError.invalidResponse) {
        configuration.shouldFail = shouldFail
        configuration.failureError = error
    }

    func reset() {
        fetchCallCount = 0
        lastFetchedEndpoint = nil
        mockedResponses.removeAll()
        configuration = Configuration()
    }

    // MARK: - Verification Methods

    func verifyFetchCalled(times: Int) -> Bool {
        fetchCallCount == times
    }

    func verifyEndpointFetched(_ endpoint: String) -> Bool {
        lastFetchedEndpoint == endpoint
    }
}
