import GroupActivities
import SwiftUI

struct ContentView: View {
    @StateObject var game = Game()
    @StateObject var groupStateObserver = GroupStateObserver()
    
    var body: some View {
        ZStack {
            if let session = game.groupSession {
                GameView(game: game, session: session)
            } else {
                WaitingRoomView(
                    isEligibleForGroupSession: groupStateObserver.isEligibleForGroupSession,
                    startShareing: { game.startSharing() }
                )
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
