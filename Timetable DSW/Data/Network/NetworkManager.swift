//
//  NetworkManager.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Combine
import Foundation

actor NetworkManager: NetworkManagerProtocol {
    // MARK: - Configuration
    
    struct Configuration {
        struct Constants {
            let requestTimeout: TimeInterval = 300 //70
            let resourceTimeout: TimeInterval = 300 //90
        }
        
        static let constants = Constants()
    }
    
    // MARK: - Properties
    
    private let baseURL: String
    private let session: URLSession
    
    // MARK: - Initialization
    
    init(baseURL: String = "https://api.dsw.wtf") {
        self.baseURL = baseURL
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Configuration.constants.requestTimeout
        config.timeoutIntervalForResource = Configuration.constants.resourceTimeout
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Public Methods
    
    func fetch<T: Decodable>(endpoint: String) async throws -> T {
        let url = try buildURL(for: endpoint)
        let request = buildRequest(for: url)
        
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        
        return try await MainActor.run { try JSONDecoder().decode(T.self, from: data) }
    }
    
    // MARK: - Private Methods
    
    private func buildURL(for endpoint: String) throws -> URL {
        let urlString = "\(baseURL)\(endpoint)"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        return url
    }
    
    private func buildRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = Configuration.constants.requestTimeout
        return request
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}
