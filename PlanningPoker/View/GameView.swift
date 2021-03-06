import SwiftUI
import GroupActivities

struct GameView: View {
    var state: GameState
    var playCard: (Card) -> Void
    var reset: () -> Void
    
    var body: some View {
        List {
            Section(header: Text("ćć è")) {
                ForEach(state.activeParticipants, id: \.self) { participant in
                    VStack(alignment: .leading) {
                        if let card = state.cardPlayedByParticipant(participant) {
                            let isMyself = participant == state.localParticipant
                            let isHidden = !isMyself && !state.areAllParticipantsPlayed
                            Text(isHidden ? "đââïž æ±șćź" : card.value.description)
                        } else {
                            Text("đ€ èăäž­")
                        }
                        
                        if participant == state.localParticipant {
                            Text("èȘć")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                    }
                }
            }
            
            Section(header: Text("ă«ăŒă")) {
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem(), GridItem()]) {
                    ForEach(Card.all, id: \.self) { card in
                        Button(action: { playCard(card) }) {
                            Text(card.value.description)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(state.cardPlayedByMyself() == card ? .blue : nil)
                    }
                }
            }
            
            Section(header: Text("æäœ")) {
                Button("ăȘă»ăă", action: reset)
            }
        }
    }
}

private extension UUID {
    static func mock(_ number: Int) -> Self {
        UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", number))")!
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(
            state: .init(
                activeParticipants: [.mock(1)],
                localParticipant: .mock(1),
                playedCards: []
            ),
            playCard: { _ in },
            reset: {}
        )
        
        GameView(
            state: .init(
                activeParticipants: [
                    .mock(1),
                    .mock(2),
                ],
                localParticipant: .mock(1),
                playedCards: [
                    .init(
                        card: .all[0],
                        participantID: .mock(1)
                    ),
                ]
            ),
            playCard: { _ in },
            reset: {}
        )
        
        GameView(
            state: .init(
                activeParticipants: [
                    .mock(1),
                    .mock(2),
                ],
                localParticipant: .mock(1),
                playedCards: [
                    .init(
                        card: .all[0],
                        participantID: .mock(1)
                    ),
                    .init(
                        card: .all[1],
                        participantID: .mock(2)
                    ),
                ]
            ),
            playCard: { _ in },
            reset: {}
        )
    }
}
