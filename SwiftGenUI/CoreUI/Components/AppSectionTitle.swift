
import SwiftUI

struct AppSectionTitle: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 15, weight: .semibold, design: .default))
            .foregroundStyle(.white)
    }
}
