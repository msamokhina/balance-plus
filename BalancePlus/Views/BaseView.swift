import SwiftUI

struct BaseView<Content>: View where Content: View {
    let title: String
    let content: () -> Content
    
    var body: some View {
        NavigationStack {
            VStack {
                content()
            }
            .background(Color("BackgroundColor"))
            .navigationTitle(title)
        }.tint(Color("NavigationColor"))
    }
}

#Preview {
    let content: () -> some View = { Text("Hello, World!") }
    BaseView(
        title: "Base view",
        content: content
    )
}
