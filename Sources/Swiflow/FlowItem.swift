import SwiftUI

/// A simple view for displaying text items in a flow layout.
public struct FlowItem: View {
    /// The text to display in the flow item.
    public let text: String
    
    /// Creates a new FlowItem with the given text.
    public init(text: String) {
        self.text = text
    }
    
    public var body: some View {
        Text(text)
            .padding(6)
            .font(.callout)
            .padding(.horizontal, 3)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
