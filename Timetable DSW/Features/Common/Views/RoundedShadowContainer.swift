import SwiftUI

public struct RoundedShadowContainer<Content: View>: View {
    // MARK: - Constants (без Configuration)

    private let overlayOpacity: Double = 0.3
    private let defaultBlurOpacity: Double = 1.0

    // MARK: - Properties

    private let corners: UIRectCorner
    private let cornerRadius: CGFloat
    private let fill: Color?
    private let blurMaterial: Material?
    private let blurOpacity: Double
    private let shadow: ShadowStyle
    private let contentInsets: EdgeInsets
    private let outerPadding: EdgeInsets
    private let ignoresSafeAreaEdges: Edge.Set?
    private let content: Content

    // MARK: - Initialization

    public init(
        corners: UIRectCorner = .allCorners,
        cornerRadius: CGFloat = AppCornerRadius.large.value,
        fill: Color? = nil,
        blurMaterial: Material? = nil,
        blurOpacity: Double = 1.0,
        shadow: ShadowStyle = ShadowStyle(),
        contentInsets: EdgeInsets = .init(),
        outerPadding: EdgeInsets = .init(),
        ignoresSafeAreaEdges: Edge.Set? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.corners = corners
        self.cornerRadius = cornerRadius
        self.fill = fill
        self.blurMaterial = blurMaterial
        self.blurOpacity = blurOpacity
        self.shadow = shadow
        self.contentInsets = contentInsets
        self.outerPadding = outerPadding
        self.ignoresSafeAreaEdges = ignoresSafeAreaEdges
        self.content = content()
    }

    // MARK: - Body

    public var body: some View {
        content
            .padding(contentInsets)
            .background {
                backgroundView
            }
            .padding(outerPadding)
    }

    // MARK: - Subviews

    private var backgroundView: some View {
        Group {
            if let material = blurMaterial {
                blurBackground(material: material)
            } else if let fillColor = fill {
                solidBackground(color: fillColor)
            }
        }
        .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
        .ignoresSafeArea(edges: ignoresSafeAreaEdges ?? [])
    }

    private func blurBackground(material: Material) -> some View {
        RoundedCorner(radius: cornerRadius, corners: corners)
            .fill(material)
            .opacity(blurOpacity)
            .overlay {
                if let fillColor = fill {
                    RoundedCorner(radius: cornerRadius, corners: corners)
                        .fill(fillColor.opacity(overlayOpacity))
                }
            }
    }

    private func solidBackground(color: Color) -> some View {
        RoundedCorner(radius: cornerRadius, corners: corners)
            .fill(color)
    }
}
