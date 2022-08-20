//
//  ContentView.swift
//  Sprite Fonts
//
//  Created by Jayden Irwin on 2021-02-15.
//

import SwiftUI
import WelcomeKit
import StoreKit

struct AllFamiliesView: View {
    
    enum HUDMessage {
        case installed, uninstalled
    }
    
    static let defaultCustomString = "The quick brown fox jumps over the lazy dog and runs away."
    
    let welcomeFeature1 = WelcomeFeature(image: Image(systemName: "t.square"), title: "Preview", body: "Preview custom text in all fonts.")
    let welcomeFeature2 = WelcomeFeature(image: Image(systemName: "line.horizontal.3.decrease.circle"), title: "Filter", body: "Filter by theme, size, or features.")
    let welcomeFeature3 = WelcomeFeature(image: Image(systemName: "arrow.up.forward.app"), title: "Use Anywhere", body: "Use installed fonts in other apps.")
    
    let appStoreVC: SKStoreProductViewController = {
        let vc = SKStoreProductViewController()
        vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: 1437835952]) { (result, error) in
            print(error?.localizedDescription)
        }
        return vc
    }()
    
    var families: [FontFamily] {
        FontFamily.allFamilies.filter({
            let tags = Set($0.tags)
            if tags.intersection(excludeTags).isEmpty, minCapHeight <= $0.capHeight, $0.capHeight <= maxCapHeight {
                return filterTags.isEmpty || filterTags.isSubset(of: tags)
            }
            return false
        })
    }
    
    @AppStorage(UserDefaults.Key.whatsNewVersion) var whatsNewVersion = 0
    
    @ObservedObject var provider = FontProvider.shared
    
    @State var customString = AllFamiliesView.defaultCustomString
    @State var showingCustomString = false
    @State var previewMode = FamilyDetailView.PreviewMode.sample
    @State var showingWelcome = false
    @State var showingFilters = false
    @State var showingSubmission = false
    @State var hudMessage: HUDMessage?
    
    // Filters
    @State var filterTags = Set<FontFamily.Tag>()
    @State var excludeTags = Set<FontFamily.Tag>()
    @State var minCapHeight = 1
    @State var maxCapHeight = Int.max
    @State var smallCapHeight = false
    @State var mediumCapHeight = false
    @State var largeCapHeight = false
    
    var filtersActive: Bool {
        !filterTags.isEmpty || !excludeTags.isEmpty || minCapHeight != 1 || maxCapHeight != Int.max
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(families) { (family) in
                    NavigationLink(destination: FamilyDetailView(previewMode: $previewMode, customString: $customString, hudMessage: $hudMessage, family: family)) {
                        HStack {
                            Text(showingCustomString ? customString : family.name)
                                .font(Font.custom(family.fontNames.first ?? "", size: family.displaySize))
                                .lineLimit(1)
                            if family.isRegistered {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.small)
                            }
                        }
                    }
                    .draggable(family.fonts.first!)
                }
            }
            .navigationTitle("Sprite Fonts")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingCustomString.toggle()
                    } label: {
                        Image(systemName: showingCustomString ? "t.square.fill" : "t.square")
                    }
                    Button {
                        showingFilters = true
                    } label: {
                        Image(systemName: filtersActive ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
                    }
                }
                #if !targetEnvironment(macCatalyst)
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            scene.windows.first?.rootViewController?.present(appStoreVC, animated: true)
                        }
                    } label: {
                        Image("Sprite Pencil")
                    }
                    Spacer()
                    Button {
                        showingSubmission = true
                    } label: {
                        if #available(iOS 14.5, *) {
                            Label("Submit Your Font", systemImage: "envelope")
                                .labelStyle(TitleAndIconLabelStyle())
                        } else {
                            // Fallback on earlier versions
                            HStack {
                                Image(systemName: "envelope")
                                Text("Submit Your Font")
                            }
                        }
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingWelcome, onDismiss: {
                if whatsNewVersion < SpriteFontsApp.appWhatsNewVersion {
                    whatsNewVersion = SpriteFontsApp.appWhatsNewVersion
                }
            }, content: {
                WelcomeView(isFirstLaunch: whatsNewVersion == 0, appName: "Sprite Fonts", feature1: welcomeFeature1, feature2: welcomeFeature2, feature3: welcomeFeature3)
            })
            .sheet(isPresented: $showingFilters) {
                FilterView(filterTags: $filterTags, excludeTags: $excludeTags, minCapHeight: $minCapHeight, maxCapHeight: $maxCapHeight, smallCapHeight: $smallCapHeight, mediumCapHeight: $mediumCapHeight, largeCapHeight: $largeCapHeight)
            }
            .sheet(isPresented: $showingSubmission) {
                FontSubmissionView()
            }
        }
        .overlay(
            ConfirmationHUD(systemName: "checkmark", message: "Font Installed")
                .opacity(hudMessage == .installed ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.2))
        )
        .onAppear() {
            if whatsNewVersion < SpriteFontsApp.appWhatsNewVersion {
                showingWelcome = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AllFamiliesView()
    }
}
