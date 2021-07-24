import GroupActivities

struct GameState {
    var activeParticipants: [Participant.ID]
    var localParticipant: Participant.ID
    var playedCards: [PlayedCard]
    
    var areAllParticipantsPlayed: Bool {
        activeParticipants.count == playedCards.count
    }
    
    func cardPlayedByParticipant(_ id: Participant.ID) -> Card? {
        playedCards.first { $0.participantID == id }?.card
    }
    
    func cardPlayedByMyself() -> Card? {
        cardPlayedByParticipant(localParticipant)
    }
}

extension GameState {
    init(activeParticipants: Set<Participant>, localParticipant: Participant, playedCards: [PlayedCard]) {
        self.activeParticipants = activeParticipants.map(\.id)
            .sorted { $0.uuidString < $1.uuidString }
        self.localParticipant = localParticipant.id
        self.playedCards = playedCards
    }
}
