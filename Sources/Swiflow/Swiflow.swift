import SwiftUI

public struct Swiflow<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    public let items: Data
    public let spacing: CGFloat
    public let content: (Data.Element) -> Content
    
    @State private var elementsSize: [Int: CGSize] = [:]
    
    public init(
        _ items: Data,
        spacing: CGFloat = 8,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.items = items
        self.spacing = spacing
        self.content = content
    }
    
    public var body: some View {
        var totalWidth = CGFloat.zero
        var rows: [[(index: Int, item: Data.Element)]] = [[]]
        var currentRow = 0
        let itemsArray = Array(items)
        
        for (index, item) in itemsArray.enumerated() {
            let itemSize = elementsSize[index, default: CGSize(width: 100, height: 100)]
            
            if totalWidth + itemSize.width + spacing > UIScreen.main.bounds.width - 32 {
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
    
    private struct ItemSizePreferenceKey: PreferenceKey {
        static var defaultValue: [Int: CGSize] { [:] }
        static func reduce(value: inout [Int: CGSize], nextValue: () -> [Int: CGSize]) {
            value.merge(nextValue(), uniquingKeysWith: { $1 })
        }
    }
}

#Preview {
    let items = ["Swift", "Xcode", "Apple Intelligence", "Combine", "CreateML", "SwiftTesting", "Vision", "RealityKit", "SwiftUI", "SwiftData"]
    
    Swiflow(items) { item in
        FlowItem(text: item)
    }
    .padding(10)
    .background(.secondary.opacity(0.1), in: .rect(cornerRadius: 10, style: .continuous).stroke(lineWidth: 4))
    .padding(.horizontal, 20)
    .frame(maxHeight: .infinity)
    .background(Color(uiColor: .systemGroupedBackground))
}

struct FlowItem: View {
    let text: String
    
    var body: some View {
        Text(text)
            .padding(6)
            .font(.callout)
            .padding(.horizontal, 3)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
