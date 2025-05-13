import SwiftUI
import Swiflow

struct ContentView: View {
    let items = ["Swift", "Xcode", "Apple Intelligence", "Combine", "CreateML", "SwiftTesting", "Vision", "RealityKit", "SwiftUI", "SwiftData"]
    
    var body: some View {
        VStack {
            Text("Swiflow Example")
                .font(.largeTitle)
                .padding()
            
            Swiflow(items) { item in
                FlowItem(text: item)
            }
            .padding(10)
            .background(
                .secondary.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(lineWidth: 4)
            )
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview {
    ContentView()
}
