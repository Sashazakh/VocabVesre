import SwiftUI

struct WordCardView: View {
    let word: Word
    let onTapAction: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTapAction) {
            VStack(alignment: .leading) {
                Text("\(word.translation)")
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 10)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Text("\(word.nativeWord)")
                    .font(.callout)    
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }

        }
    }
}
