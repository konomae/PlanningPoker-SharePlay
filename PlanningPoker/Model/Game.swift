import Foundation
import Combine
import SwiftUI
import GroupActivities

@MainActor
final class Game: ObservableObject {
    @Published private(set) var groupSession: GroupSession<PlanningPoker>?
    @Published private(set) var playedCards: [PlayedCard] = []
    
    private var subscriptions = Set<AnyCancellable>()
    
    func configureGroupSession(_ groupSession: GroupSession<PlanningPoker>) {
        self.groupSession = groupSession
        
        groupSession.$state
            .sink { state in
                if case .invalidated = state {
                    self.groupSession = nil
                }
            }
            .store(in: &subscriptions)
        
        groupSession.join()
    }
    
    func startSharing() {
        PlanningPoker().activate()
    }
    
    func playCard(_ card: Card) {
        guard let myself = groupSession?.localParticipant else {
            return
        }
        
        var cards = playedCards.filter { $0.participantID != myself.id }
        cards.append(PlayedCard(card: card, participantID: myself.id))
        playedCards = cards
    }
    
    func isCardSelected(_ card: Card) -> Bool {
        guard let myself = groupSession?.localParticipant else {
            return false
        }
        
        return playedCards
            .first { $0.participantID == myself.id }?.card == card
    }
}
