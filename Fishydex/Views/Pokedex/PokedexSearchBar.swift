import SwiftUI

/// A search bar styled like a Pokedex data input terminal.
///
/// Features a dark background, green border accent, magnifying glass icon,
/// monospace placeholder text, and a clear button.
struct PokedexSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search species..."

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            // Magnifying glass icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.screenGlow.opacity(0.7))

            // Text field
            TextField("", text: $text, prompt: promptText)
                .font(.dataReadout(size: 14))
                .foregroundStyle(Color.screenGlow)
                .tint(Color.screenGlow)
                .focused($isFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            // Clear button
            if !text.isEmpty {
                Button {
                    text = ""
                    HapticsService.buttonTap()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.screenGlow.opacity(0.6))
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.screenBackground.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    isFocused
                        ? Color.screenGlow.opacity(0.6)
                        : Color.screenGlow.opacity(0.25),
                    lineWidth: 1.5
                )
        )
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }

    private var promptText: Text {
        Text(placeholder)
            .font(.dataReadout(size: 14))
            .foregroundColor(Color.screenGlow.opacity(0.35))
    }
}

// MARK: - Preview

#Preview("Pokedex Search Bar") {
    VStack(spacing: 20) {
        PokedexSearchBar(text: .constant(""))
        PokedexSearchBar(text: .constant("Northern"))
    }
    .padding()
    .background(Color.screenBackground)
}
