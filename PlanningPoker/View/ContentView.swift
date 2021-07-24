import GroupActivities
import SwiftUI

struct ContentView: View {
    @StateObject var game = Game()
    @StateObject var groupStateObserver = GroupStateObserver()
    
    var body: some View {
        ZStack {
            if let session = game.groupSession {
                SessionView(game: game, session: session) { gameState in
                    GameView(
                        state: gameState,
                        playCard: { game.playCard($0) },
                        reset: { game.reset() }
                    )
                }
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

private struct SessionView<Content: View>: View {
    @ObservedObject var game: Game
    @ObservedObject var session: GroupSession<PlanningPoker>
    @ViewBuilder var content: (GameState) -> Content
    
    var body: some View {
        content(
            GameState(
                activeParticipants: session.activeParticipants,
                localParticipant: session.localParticipant,
                playedCards: game.playedCards
            )
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
