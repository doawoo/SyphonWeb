import SwiftUI

struct UtilityView: View {
  @State private var urlString: String = ""
  var onNavigate: ((String) -> Void)? = nil
  
  var body: some View {
    GeometryReader { geometry in
      HStack(spacing: 5) {
        if #available(macOS 12.0, *) {
            TextField("Enter URL", text: $urlString)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .disableAutocorrection(true)
              .onSubmit {
                if !urlString.isEmpty {
                  onNavigate?(urlString)
                }
              }
        } else {
            // Fallback on earlier versions
        }
        
        Button("Go") {
          if !urlString.isEmpty {
            onNavigate?(urlString)
          }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
      }
      .padding(.horizontal)
      .frame(
        minWidth: geometry.size.width, maxWidth: geometry.size.width,
        minHeight: geometry.size.height, maxHeight: geometry.size.height)
    }
  }
}
