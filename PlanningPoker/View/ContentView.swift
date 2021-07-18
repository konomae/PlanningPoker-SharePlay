import GroupActivities
import SwiftUI

struct ParticipantsSection: View {
    @ObservedObject var session: GroupSession<PlanningPoker>
    var playedCards: [PlayedCard]
    
    var participants: [Participant] {
        session.activeParticipants
            .sorted { $0.id.uuidString < $1.id.uuidString }
    }
    
    var areAllParticipantsPlayed: Bool {
        session.activeParticipants.count == playedCards.count
    }
    
    var body: some View {
        Section(header: Text("参加者")) {
            ForEach(Array(participants.enumerated()), id: \.element.id) { index, participant in
                VStack(alignment: .leading) {
                    HStack {
                        if let card = playedCards.first(where: { $0.participantID == participant.id })?.card {
                            let isMyself = participant.id == session.localParticipant.id
                            let isHidden = !isMyself && !areAllParticipantsPlayed
                            Text(isHidden ? "🙈" : card.value.description)
                        } else {
                            ProgressView()
                        }
                    }
                    
                    if participant.id == session.localParticipant.id {
                        Text("自分")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject var game = Game()
    @StateObject var groupStateObserver = GroupStateObserver()
    
    var body: some View {
        List {
            if let session = game.groupSession {
                ParticipantsSection(session: session, playedCards: game.playedCards)
            } else {
                Section {
                    Text("🙈FaceTimeを開始してSharePlayに参加してください")
                    
                    Button {
                        game.startSharing()
                    } label: {
                        HStack {
                            Image(systemName: "person.2.fill")
                            
                            Text("SharePlayに参加")
                        }
                    }
                    .disabled(!groupStateObserver.isEligibleForGroupSession)
                }
            }
            
            Section(header: Text("操作")) {
                Button("リセット") {}
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
        }
        .task {
            for await session in PlanningPoker.sessions() {
                game.configureGroupSession(session)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
