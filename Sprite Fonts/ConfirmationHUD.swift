//
//  ConfirmationHUD.swift
//  Sprite Fonts
//
//  Created by Jayden Irwin on 2021-02-16.
//

import SwiftUI

struct ConfirmationHUD: View {
    
    @State var systemName: String
    @State var message: String
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            Image(systemName: systemName)
                .imageScale(.large)
                .font(Font.system(size: 72, weight: .medium))
            Text(message)
                .font(Font.system(size: 22, weight: .semibold))
                .multilineTextAlignment(.center)
        }
        .padding(30)
        .frame(width: 252, height: 270)
        .foregroundColor(.gray)
        .background(Material.regular)
        .cornerRadius(12)
    }
}

struct ConfirmationHUD_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationHUD(systemName: "checkmark", message: "Installed")
    }
}
