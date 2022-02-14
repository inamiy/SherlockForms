import SwiftUI

struct CustomView: View
{
    var body: some View
    {
        VStack(spacing: 16) {
            Text("🕵️‍♂️").font(.system(size: 64))
            Text("Hello SherlockForms!").font(.title)
            Text("""
                `SherlockForms` is an elegant SwiftUI Form builder to create a searchable Settings screen and even DebugMenu for your app!
                """)
                .frame(alignment: .leading)
        }
        .padding()
    }
}

// MARK: - Previews

struct CustomView_Previews: PreviewProvider
{
    static var previews: some View
    {
        CustomView()
    }
}

