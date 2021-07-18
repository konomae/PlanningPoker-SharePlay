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
                VStack(alignment: .leading) {
                    HStack {
                        Text(participant.id.uuidString)
                        
                        Spacer()
                        
                        ProgressView()
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
    @State var selectedCard: Card?
    
    @StateObject var game = Game()
    @StateObject var groupStateObserver = GroupStateObserver()
    
    var body: some View {
        List {
            if let session = game.groupSession {
                ParticipantsSection(session: session)
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
                Button("リセット", action: reset)
            }
            
            Section(header: Text("カード")) {
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem(), GridItem()]) {
                    ForEach(Card.all, id: \.self) { card in
                        Button(action: { selectedCard = card }) {
                            Text(card.value.description)
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
