import SwiftUI

struct UtilityView: View {
  @State private var urlString: String = ""
  var onNavigate: ((String) -> Void)? = nil

  var body: some View {
    if #available(macOS 12.0, *) {
      GeometryReader { geometry in
        HStack(spacing: 5) {
          TextField("Enter URL", text: $urlString)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .disableAutocorrection(true)
            .onSubmit {
              if !urlString.isEmpty {
                onNavigate?(urlString)
              }
            }
          Button("Go") {
            if !urlString.isEmpty {
              onNavigate?(urlString)
            }
          }
        }

        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .frame(
          minWidth: geometry.size.width, maxWidth: geometry.size.width,
          minHeight: geometry.size.height, maxHeight: geometry.size.height)
      }
    } else {
      Text("Your operating system is not supported!")
    }
  }
}
