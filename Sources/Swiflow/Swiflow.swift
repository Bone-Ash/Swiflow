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
        var totalWidth = CGFloat.zero
        var rows: [[(index: Int, item: Data.Element)]] = [[]]
        var currentRow = 0
        let itemsArray = Array(items)
        let screenWidth = UIScreen.main.bounds.width - 32 // Account for padding
        
        // Calculate rows based on item sizes
        for (index, item) in itemsArray.enumerated() {
            let itemSize = elementsSize[index, default: CGSize(width: 100, height: 100)]
            
            if totalWidth + itemSize.width + spacing > screenWidth {
                currentRow += 1
                rows.append([])
                totalWidth = 0
            }
            
            rows[currentRow].append((index, item))
            totalWidth += itemSize.width + spacing
        }
        
        return VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: spacing) {
                    ForEach(rows[rowIndex], id: \.index) { tuple in
                        content(tuple.item)
                            .fixedSize()
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(key: ItemSizePreferenceKey.self,
                                                    value: [tuple.index: geo.size])
                                }
                            )
                    }
                    Spacer()
                }
            }
        }
        .onPreferenceChange(ItemSizePreferenceKey.self) { sizes in
            Task { @MainActor in
                self.elementsSize = sizes
            }
        }
    }
    
    // MARK: - Helper Types
    
    private struct ItemSizePreferenceKey: PreferenceKey {
        static var defaultValue: [Int: CGSize] { [:] }
        static func reduce(value: inout [Int: CGSize], nextValue: () -> [Int: CGSize]) {
            value.merge(nextValue(), uniquingKeysWith: { $1 })
        }
    }
}
