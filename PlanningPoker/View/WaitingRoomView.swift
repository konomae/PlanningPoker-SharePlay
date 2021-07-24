import SwiftUI

struct WaitingRoomView: View {
    let isEligibleForGroupSession: Bool
    let startShareing: () -> Void
    
    var body: some View {
        List {
            Section {
                Text("🙈FaceTimeを開始してSharePlayに参加してください")
                
                Button(action: startShareing) {
                    HStack {
                        Image(systemName: "person.2.fill")
                        
                        Text("SharePlayに参加")
                    }
                }
                .disabled(!isEligibleForGroupSession)
            }
        }
    }
}

struct WaitingRoomView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingRoomView(
            isEligibleForGroupSession: false,
            startShareing: {}
        )
        
        WaitingRoomView(
            isEligibleForGroupSession: true,
            startShareing: {}
        )
    }
}
