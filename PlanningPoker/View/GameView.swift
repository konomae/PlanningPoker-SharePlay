import SwiftUI
import GroupActivities

struct GameView: View {
    @ObservedObject var game: Game
    @ObservedObject var session: GroupSession<PlanningPoker>
    
    var participants: [Participant] {
        session.activeParticipants
            .sorted { $0.id.uuidString < $1.id.uuidString }
    }
    
    var areAllParticipantsPlayed: Bool {
        session.activeParticipants.count == game.playedCards.count
    }
    
    var body: some View {
        List {
            Section {
                ForEach(Array(participants.enumerated()), id: \.element.id) { index, participant in
                    Text(participant.id.uuidString)
                }
            }
            
            Section(header: Text("参加者")) {
                ForEach(Array(participants.enumerated()), id: \.element.id) { index, participant in
                    VStack(alignment: .leading) {
                        if let card = game.playedCards.first(where: { $0.participantID == participant.id })?.card {
                            let isMyself = participant.id == session.localParticipant.id
                            let isHidden = !isMyself && !areAllParticipantsPlayed
                            Text(isHidden ? "🙆‍♂️ 決定" : card.value.description)
                        } else {
                            Text("🤔 考え中")
                        }
                        
                        if participant.id == session.localParticipant.id {
                            Text("自分")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                    }
                }
            }
            
            Section(header: Text("カード")) {
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem(), GridItem()]) {
                    ForEach(Card.all, id: \.self) { card in
                        Button(action: { game.playCard(card) }) {
                            Text(card.value.description)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(game.isCardSelected(card) ? .blue : nil)
                    }
                }
            }
            
            Section(header: Text("操作")) {
                Button("リセット") { game.reset() }
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
