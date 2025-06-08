import SwiftUI

/// A flow layout container that arranges items in multiple rows.
public struct Swiflow<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    // MARK: - Properties
    
    /// The collection of items to display.
    public let items: Data
    
    /// Horizontal and vertical spacing between items.
    public let spacing: CGFloat
    
    /// A closure that creates the view for a single item.
    public let content: (Data.Element) -> Content
    
    /// Tracks the size of each element for layout calculations.
    @State private var elementsSize: [Int: CGSize] = [:]
    
    /// Container width
    @State private var containerWidth: CGFloat = 0
    
    // MARK: - Initialization
    
    /// Creates a new flow layout with the given items and configuration.
    /// - Parameters:
    ///   - items: The collection of items to display.
    ///   - spacing: The spacing between items (default is 8 points).
    ///   - content: A closure that creates the view for a single item.
    public init(
        _ items: Data,
        spacing: CGFloat = 8,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.items = items
        self.spacing = spacing
        self.content = content
    }
    
    // MARK: - Body
    
    public var body: some View {
        ViewThatFits(in: .horizontal) {
            calculatedContent
                .geometryGroup()
                .measureSize { size in
                    containerWidth = size.width
                }
        }
    }
    
    private var calculatedContent: some View {
        let layout = computeRows(availableWidth: containerWidth)
        
        return VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<layout.count, id: \.self) { rowIndex in
                HStack(spacing: spacing) {
                    ForEach(layout[rowIndex], id: \.index) { tuple in
                        content(tuple.item)
                            .fixedSize()
                            .measureSize { size in
                                elementsSize[tuple.index] = size
                            }
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func computeRows(availableWidth: CGFloat) -> [[(index: Int, item: Data.Element)]] {
        var rows: [[(index: Int, item: Data.Element)]] = []
        var currentRowWidth = CGFloat.zero
        var currentRowItems: [(index: Int, item: Data.Element)] = []
        let itemsArray = Array(items)
    
        // Calculate rows based on item sizes
        for (index, item) in itemsArray.enumerated() {
            let itemSize = elementsSize[index, default: CGSize(width: 100, height: 30)]
    
            let spacingNeeded = currentRowItems.isEmpty ? 0 : spacing
            let additionalWidth = spacingNeeded + itemSize.width
    
            if !currentRowItems.isEmpty && currentRowWidth + additionalWidth > availableWidth {
                rows.append(currentRowItems)
                currentRowItems = []
                currentRowWidth = 0
            }
    
            currentRowItems.append((index, item))
            let actualSpacingUsed = currentRowWidth > 0 ? spacing : 0
            currentRowWidth += actualSpacingUsed + itemSize.width
        }
    
        if !currentRowItems.isEmpty {
            rows.append(currentRowItems)
        }
    
        return rows.isEmpty ? [[]] : rows
    }
}

// Extension to measure view sizes without using GeometryReader
extension View {
    func measureSize(perform action: @escaping (CGSize) -> Void) -> some View {
        self.background(
            SizeCalculator()
                .onPreferenceChange(SizePreferenceKey.self, perform: action)
        )
    }
}

// Helper view to calculate size
private struct SizeCalculator: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: SizePreferenceKey.self,
                value: geometry.size
            )
        }
    }
}

// Preference key for size calculations
private struct SizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
