import SwiftUI

struct UtilityView: View {
  var body: some View {
    GeometryReader { geometry in
      HStack {
        Text("Tools Here")
      }
      .frame(
        minWidth: geometry.size.width, maxWidth: geometry.size.width,
        minHeight: geometry.size.height, maxHeight: geometry.size.height)
    }
  }
}
