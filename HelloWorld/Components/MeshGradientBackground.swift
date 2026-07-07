import SwiftUI

struct MeshGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Theme.meshTop, Theme.meshBottom],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
