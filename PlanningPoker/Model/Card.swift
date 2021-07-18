struct Card: Hashable {
    var value: Int
}

extension Card {
    static let all: [Self] = [
        Card(value: 1),
        Card(value: 2),
        Card(value: 3),
        Card(value: 5),
        Card(value: 8),
        Card(value: 13),
        Card(value: 21),
        Card(value: 34),
        Card(value: 55),
        Card(value: 89),
    ]
}
