import Foundation
import Combine
import SwiftUI
import GroupActivities

@MainActor
final class Game: ObservableObject {
    @Published private(set) var groupSession: GroupSession<PlanningPoker>?
    
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
}
