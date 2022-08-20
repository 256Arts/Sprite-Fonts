//
//  FontDetailView.swift
//  Sprite Fonts
//
//  Created by Jayden Irwin on 2021-02-15.
//

import SwiftUI
import StoreKit
import JaydenCodeGenerator

struct FamilyDetailView: View {
    
    enum PreviewMode {
        case sample, custom
    }
    
    @AppStorage(UserDefaults.Key.fontsViewed) var fontsViewed = 0
    @AppStorage(UserDefaults.Key.fontsInstalled) var fontsInstalled = 0
    
    @ObservedObject var provider = FontProvider.shared
    
    @Binding var previewMode: PreviewMode
    @Binding var customString: String
    @Binding var hudMessage: AllFamiliesView.HUDMessage?
    
    @State var family: FontFamily
    @State var showingJaydenCode = false
    
    var jaydenCode: String {
        JaydenCodeGenerator.generateCode(secret: "AJA3OQ2V5J")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Preview Mode", selection: $previewMode) {
                    Image(systemName: "text.aligncenter")
                        .tag(PreviewMode.sample)
                    Image(systemName: "text.cursor")
                        .tag(PreviewMode.custom)
                }
                .pickerStyle(SegmentedPickerStyle())
                if previewMode == .sample {
                    Text("ABCDEFGHIJKLM\nNOPQRSTUVWXYZ\nabcdefghijklm\nnopqrstuvwxyz\n1234567890")
                        .multilineTextAlignment(.center)
                        .font(Font.custom(family.fontNames.first ?? "", size: family.displaySize * 2.0))
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, minHeight: 400)
                } else {
                    #if targetEnvironment(macCatalyst) // Workaround for catalyst bug that screws up line height in TextEditor view.
                    Text("The quick brown fox jumps over the lazy dog and runs away.")
                        .multilineTextAlignment(.center)
                        .font(Font.custom(family.fontNames.first ?? "", size: family.displaySize * 2.0))
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, minHeight: 400)
                    #else
                    TextEditor(text: $customString)
                        .multilineTextAlignment(.center)
                        .font(Font.custom(family.fontNames.first ?? "", size: family.displaySize * 2.0))
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, minHeight: 400)
                    #endif
                }
                LabeledValue(value: family.author.name, label: "Author", url: family.author.url)
                LabeledValue(value: "\(family.capHeight) px", label: "Cap Height")
                LabeledValue(value: family.licence.rawValue, label: "Licence")
                Spacer()
            }
            .padding()
        }
        .navigationTitle(family.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
//            if let font = family.fonts.first {
//                ShareLink(item: font)
//            }
            Button {
                if family.isRegistered {
                    CTFontManagerUnregisterFontURLs(family.fonts.map({ $0.fileURL }) as CFArray, .persistent) { (errors, done) -> Bool in
//                        if done {
//                            hudMessage = .uninstalled
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
//                                hudMessage = nil
//                            }
//                        }
                        return true
                    }
                } else {
                    CTFontManagerRegisterFontURLs(family.fonts.map({ $0.fileURL }) as CFArray, .persistent, true) { (errors, done) -> Bool in
                        if done {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if family.isRegistered {
                                    fontsInstalled += 1
                                    hudMessage = .installed
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                        hudMessage = nil
                                    }
                                }
                            }
                        }
                        print(errors, done)
                        return true
                    }
                }
            } label: {
                if family.isRegistered {
                    Image(systemName: "checkmark.circle")
                } else {
                    Text("Install")
                }
            }

        }
        .onAppear() {
            fontsViewed += 1
            if (fontsViewed == 25 || fontsViewed == 100), 1 < fontsInstalled {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
        .onChange(of: customString) { (_) in
            if customString.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if customString.isEmpty {
                        customString = AllFamiliesView.defaultCustomString
                    }
                }
            } else if customString == "This is a secret" {
                showingJaydenCode = true
            }
        }
        .alert("Secret Code: \(jaydenCode)", isPresented: $showingJaydenCode) {
            Button("Copy") {
                UIPasteboard.general.string = jaydenCode
            }
            Button("OK", role: .cancel, action: { })
        }
    }
}

struct FontDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FamilyDetailView(previewMode: .constant(.sample), customString: .constant("Quick fox."), hudMessage: .constant(nil), family: FontFamily.allFamilies[0])
    }
}
