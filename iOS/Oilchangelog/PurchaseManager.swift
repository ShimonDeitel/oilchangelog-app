import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let productID = "com.shimondeitel.oilchangelog.pro.monthly"

    @Published private(set) var isPro: Bool = false
    @Published private(set) var product: Product?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(result)
            }
        }
        Task { await load() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func load() async {
        if let products = try? await Product.products(for: [Self.productID]),
           let p = products.first {
            product = p
        }
        await refreshEntitlement()
    }

    func purchase() async {
        guard let product else { return }
        guard let result = try? await product.purchase() else { return }
        switch result {
        case .success(let verification):
            await handle(verification)
        default:
            break
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlement()
    }

    private func handle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        await transaction.finish()
        await refreshEntitlement()
    }

    private func refreshEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.productID {
                isPro = true
                return
            }
        }
        isPro = false
    }
}
