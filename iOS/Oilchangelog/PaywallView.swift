import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "drop.circle")
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.accent)
                    Text("Go Pro")
                        .font(Theme.titleFont)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Multi-vehicle tracking with custom interval rules per oil type")
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.textPrimary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button {
                        Task {
                            await purchases.purchase()
                            if purchases.isPro { dismiss() }
                        }
                    } label: {
                        Text(purchases.product?.displayPrice.map { "Upgrade — \($0)" } ?? "Upgrade")
                            .font(Theme.headingFont)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .accessibilityIdentifier("purchaseButton")
                    .padding(.horizontal)

                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("restorePaywallButton")

                    Button("Not now") { dismiss() }
                        .accessibilityIdentifier("dismissPaywallButton")
                        .foregroundStyle(Theme.textPrimary.opacity(0.6))
                }
                .padding()
            }
        }
    }
}
