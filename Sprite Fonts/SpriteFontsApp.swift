//
//  Sprite_FontsApp.swift
//  Sprite Fonts
//
//  Created by Jayden Irwin on 2021-02-15.
//

import SwiftUI

@main
struct SpriteFontsApp: App {
    
    static let appWhatsNewVersion = 1
    
    init() {
        #if DEBUG
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            AllFamiliesView()
        }
    }
}
