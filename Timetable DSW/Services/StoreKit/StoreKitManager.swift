//
//  StoreKitManager.swift
//  Timetable DSW
//
//  Created for managing in-app purchases with StoreKit 2
//

import Foundation
import StoreKit
import Combine

// MARK: - Product Types

enum ProductType: String, CaseIterable {
    case tip = "com.dswlab.timetable.tip.hotdog"           // Tip: Hotdog for developer (6.99 PLN)
    case premium = "com.dswlab.timetable.premium.pizzapepsi" // Premium: Pizza + Pepsi (19.00 PLN)

    var displayName: LocalizedString {
        switch self {
        case .tip:
            return .iapTipTitle
        case .premium:
            return .iapPremiumTitle
        }
    }

    var description: LocalizedString {
        switch self {
        case .tip:
            return .iapTipDescription
        case .premium:
            return .iapPremiumDescription
        }
    }
}

// MARK: - Purchase Result

enum PurchaseResult {
    case success(ProductType)
    case cancelled
    case pending
    case failed(Error)
}

// MARK: - StoreKit Manager

@MainActor
final class StoreKitManager: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var products: [ProductType: Product] = [:]
    @Published private(set) var purchasedProducts: Set<ProductType> = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private var updateListenerTask: Task<Void, Never>?
    private let appStateService: DefaultAppStateService

    // MARK: - Initialization

    init(appStateService: DefaultAppStateService) {
        self.appStateService = appStateService
        updateListenerTask = listenForTransactions()

        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Public Methods

    /// Load products from App Store Connect
    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let productIds = ProductType.allCases.map { $0.rawValue }
            let storeProducts = try await Product.products(for: productIds)

            var productsDict: [ProductType: Product] = [:]
            for product in storeProducts {
                if let productType = ProductType(rawValue: product.id) {
                    productsDict[productType] = product
                }
            }

            self.products = productsDict
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("❌ StoreKit Error: Failed to load products - \(error)")
        }

        isLoading = false
    }

    /// Purchase a product
    func purchase(_ productType: ProductType) async -> PurchaseResult {
        guard let product = products[productType] else {
            return .failed(StoreKitError.productNotFound)
        }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)

                // Grant access based on product type
                await handleSuccessfulPurchase(productType: productType, transaction: transaction)

                // Finish the transaction
                await transaction.finish()

                await updatePurchasedProducts()

                isLoading = false
                return .success(productType)

            case .userCancelled:
                isLoading = false
                return .cancelled

            case .pending:
                isLoading = false
                return .pending

            @unknown default:
                isLoading = false
                return .failed(StoreKitError.unknown)
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return .failed(error)
        }
    }

    /// Restore purchases
    func restorePurchases() async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }

    /// Check if user has purchased premium
    func hasPurchasedPremium() -> Bool {
        return purchasedProducts.contains(.premium)
    }

    // MARK: - Private Methods

    private func handleSuccessfulPurchase(productType: ProductType, transaction: Transaction) async {
        switch productType {
        case .premium:
            // Grant permanent premium access
            appStateService.grantPremium()

        case .tip:
            // Tip is consumable - just record the transaction
            // No premium access granted for tips
            break
        }
    }

    private func updatePurchasedProducts() async {
        var purchased: Set<ProductType> = []

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            if let productType = ProductType(rawValue: transaction.productID) {
                // Only non-consumable purchases grant access
                if productType == .premium {
                    purchased.insert(productType)
                }
            }
        }

        self.purchasedProducts = purchased

        // Update app state based on purchases
        if purchased.contains(.premium) {
            appStateService.grantPremium()
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else {
                    continue
                }

                await self.updatePurchasedProducts()
                await transaction.finish()
            }
        }
    }
}

// MARK: - StoreKit Errors

enum StoreKitError: LocalizedError {
    case productNotFound
    case verificationFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found"
        case .verificationFailed:
            return "Transaction verification failed"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

// MARK: - Environment Key

private struct StoreKitManagerKey: EnvironmentKey {
    static let defaultValue: StoreKitManager? = nil
}

extension EnvironmentValues {
    var storeKitManager: StoreKitManager? {
        get { self[StoreKitManagerKey.self] }
        set { self[StoreKitManagerKey.self] = newValue }
    }
}

extension View {
    func storeKitManager(_ manager: StoreKitManager) -> some View {
        environment(\.storeKitManager, manager)
    }
}
