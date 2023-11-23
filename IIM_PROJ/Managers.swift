import SwiftUI

func checkSelectedTab(tabSelection: Binding<Int>) {
    var currentTab = tabSelection.wrappedValue
    print("Selected Tab: \(currentTab)")
}


struct UserInventoryView: View {
    var user: User

    var body: some View {
        VStack {
            Text("User Inventory for \(user.username)")
            // Add content for user inventory here
        }
        .navigationBarTitle("Inventory")
    }
}
