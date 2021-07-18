import GroupActivities

struct PlanningPoker: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Planning Poker"
        metadata.type = .generic
        
        return metadata
    }
}
