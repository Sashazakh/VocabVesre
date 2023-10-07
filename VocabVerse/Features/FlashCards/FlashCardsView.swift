import SwiftUI
import ComposableArchitecture

struct FlashCardsView: View {
    let store: StoreOf<FlashCardsFeature>
    
    @State private var offset: CGSize = .zero
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                if viewStore.currentIndex < viewStore.words.count {
                    Spacer()
                    GeometryReader { geo in
                        CardView(
                            word: viewStore.currentWord,
                            isFlipped: viewStore.isCurrentCardFlipped,
                            store: store
                        )
                        .offset(offset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = value.translation
                                }
                                .onEnded { value in
                                    if abs(offset.width) > 100 {
                                        if offset.width > 0 {
                                            viewStore.send(.correctWordTapped)
                                        } else {
                                            viewStore.send(.incorrectWordTapped)
                                        }
                                    }
                                    offset = .zero
                                }
                        )
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.4)) {
                                offset = CGSize(
                                    width: -UIScreen.main.bounds.width,
                                    height: 100
                                )
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                viewStore.send(.incorrectWordTapped)
                                offset = .zero
                            }
                        }) {
                            Image(systemName: "hand.thumbsdown.fill")
                                .frame(width: 100, height: 50)
                                .background(Color.red)
                                .cornerRadius(20)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewStore.send(.cardTapped)
                        }) {
                            Image(systemName: "eye.fill")
                                .frame(width: 50, height: 50)
                                .background(Color.orange)
                                .cornerRadius(20)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.4)) {
                                offset = CGSize(
                                    width: UIScreen.main.bounds.width,
                                    height: 100
                                )
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                viewStore.send(.correctWordTapped)
                                offset = .zero
                            }
                        }) {
                            Image(systemName: "hand.thumbsup.fill")
                                .frame(width: 100, height: 50)
                                .background(Color.green)
                                .cornerRadius(20)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    Text("Correct: \(viewStore.correctWordsScore)")
                        .font(.title)
                    Text("Incorrect: \(viewStore.incorrectWordScore)")
                        .font(.title)
                    
                    Button("Reset") {
                        viewStore.send(.reset)
                    }
                    .frame(width: 100, height: 50)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .foregroundColor(.white)
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .toolbar(.hidden, for: .tabBar)
        }
    }
}

struct CardView: View {
    let word: Word
    var isFlipped: Bool
    let store: StoreOf<FlashCardsFeature>
    
    var body: some View {
        WithViewStore(store, observe: \.isCurrentCardFlipped) { viewStore in
            VStack {
                HStack {
                    if !viewStore.state {
                        Text(word.nativeWord)
                            .foregroundColor(Color.white)
                            .font(.largeTitle)
                    } else {
                        Text(word.translation)
                            .foregroundColor(Color.white)
                            .font(.largeTitle)
                            .rotation3DEffect(
                                Angle(degrees: 180),
                                axis: (x: 0.0, y: 1.0, z: 0.0)
                            )
                    }
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: 350, maxHeight: 250)
                .background(Color.purple)
                .cornerRadius(10)
                .shadow(radius: 5)
                .rotation3DEffect(
                    viewStore.state ? Angle(degrees: 180) : .zero,
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                .animation(.default, value: viewStore.state)
                .onTapGesture {
                    viewStore.send(.cardTapped)
                }
            }
        }
    }
}

struct LearningView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FlashCardsView(
                store: Store(
                    initialState: FlashCardsFeature.State(
                        words: [
                            .mock(UUID()),
                            .mock(UUID()),
                            .mock(UUID()),
                            .mock(UUID())
                        ]
                    )
                ) {
                    FlashCardsFeature()
                }
            )
        }
    }
}
