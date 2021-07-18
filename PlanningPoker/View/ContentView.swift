import GroupActivities
import SwiftUI

struct ParticipantsSection: View {
    @ObservedObject var session: GroupSession<PlanningPoker>
    
    var participants: [Participant] {
        session.activeParticipants
            .sorted { $0.id.uuidString < $1.id.uuidString }
    }
    
    var body: some View {
        Section(header: Text("参加者")) {
            ForEach(participants, id: \.id) { participant in
                HStack {
                    Text(participant.id.uuidString)
                    
                    Spacer()
                    
                    if participant.id == session.localParticipant.id {
                        Text("自分")
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    var cards: [Int] = [
        1, 2, 3, 5, 8, 13, 21, 34, 55, 89
    ]
    
    @State var selectedCard: Int?
    
    @StateObject var game = Game()
    @StateObject var groupStateObserver = GroupStateObserver()
    
    var body: some View {
        List {
            if let session = game.groupSession {
                ParticipantsSection(session: session)
            } else {
                HStack {
                    Text("🙈FaceTimeを開始してください")
                }
            }
            
            Section(header: Text("操作")) {
                HStack {
                    if selectedCard == nil {
                        Text("カードを選択してください")
                    } else {
                        Text("他のユーザーの投票待ち")
                    }
                    
                    Spacer()
                    
                    ProgressView()
                }
                
                if game.groupSession == nil && groupStateObserver.isEligibleForGroupSession {
                    Button {
                        game.startSharing()
                    } label: {
                        HStack {
                            Image(systemName: "person.2.fill")
                            
                            Text("SharePlay に参加")
                        }
                    }
                }
                
                Button("リセット", action: reset)
            }
            
            Section(header: Text("カード")) {
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem(), GridItem()]) {
                    ForEach(cards, id: \.self) { card in
                        Button(role: .cancel, action: { selectedCard = card }) {
                            Text(card.description)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(selectedCard == card ? .blue : nil)
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
    
    func reset() {
        selectedCard = nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
