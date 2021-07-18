import Foundation
import Combine
import SwiftUI
import GroupActivities

@MainActor
final class Game: ObservableObject {
    @Published private(set) var groupSession: GroupSession<PlanningPoker>?
    @Published private(set) var playedCards: [PlayedCard] = []
    
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()
    
    func configureGroupSession(_ groupSession: GroupSession<PlanningPoker>) {
        self.groupSession = groupSession
        let messenger = GroupSessionMessenger(session: groupSession)
        self.messenger = messenger
        
        groupSession.$state
            .sink { state in
                if case .invalidated = state {
                    self.groupSession = nil
                }
            }
            .store(in: &subscriptions)
        
        groupSession.$activeParticipants
            .sink { activeParticipants in
                let newParticipants = activeParticipants.subtracting(groupSession.activeParticipants)

                Task {
                    try? await messenger.send(SyncMessage(playedCards: self.playedCards), to: .only(newParticipants))
                }
            }
            .store(in: &subscriptions)
        
        tasks.insert(
            Task {
                for await (message, context) in messenger.messages(of: PlayCardMessage.self) {
                    handle(message, from: context.source)
                }
            }
        )
        
        tasks.insert(
            Task {
                for await (message, _) in messenger.messages(of: SyncMessage.self) {
                    handle(message)
                }
            }
        )
        
        groupSession.join()
    }
    
    func startSharing() {
        PlanningPoker().activate()
    }
    
    func playCard(_ card: Card) {
        guard let myself = groupSession?.localParticipant else {
            return
        }
        
        let message = PlayCardMessage(card: card)
        handle(message, from: myself)
        
        Task {
            try? await messenger?.send(message)
        }
    }
    
    func isCardSelected(_ card: Card) -> Bool {
        guard let myself = groupSession?.localParticipant else {
            return false
        }
        
        return playedCards
            .first { $0.participantID == myself.id }?.card == card
    }
    
    func handle(_ message: PlayCardMessage, from participant: Participant) {
        var cards = playedCards.filter { $0.participantID != participant.id }
        cards.append(PlayedCard(card: message.card, participantID: participant.id))
        playedCards = cards
    }
    
    func handle(_ message: SyncMessage) {
        playedCards = message.playedCards
    }
}
