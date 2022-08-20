//
//  FontSubmissionView.swift
//  Sprite Fonts
//
//  Created by Jayden Irwin on 2021-04-01.
//

import SwiftUI
import MessageUI

struct FontSubmissionView: View {
    
    class MailDelegate: NSObject, MFMailComposeViewControllerDelegate {
        static let shared = MailDelegate()
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var fontName = ""
    @State var authorName = ""
    @State var authorWebsite = ""
    @State var capHeight = ""
    @State var licence: Licence = .publicDomain
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Font Name", text: $fontName)
                TextField("Author Name", text: $authorName)
                TextField("Author Website (Optional)", text: $authorWebsite)
                TextField("Cap Height", text: $capHeight)
                Picker("Licence", selection: $licence) {
                    ForEach(Licence.allCases) { (licence) in
                        Text(licence.rawValue)
                            .tag(licence)
                    }
                }
            }
            .navigationTitle("Submit Your Font")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Next") {
                        guard MFMailComposeViewController.canSendMail() else { return }
                        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            let composeVC = MFMailComposeViewController()
                            composeVC.mailComposeDelegate = MailDelegate.shared
                            composeVC.setToRecipients(["info@jaydenirwin.com"])
                            composeVC.setSubject("Sprite Font Submission")
                            composeVC.setMessageBody("Hello, I have a font submission for Sprite Fonts.\n\nFont Name: \(fontName)\nAuthor Name: \(authorName)\nAuthor Website (Optional): \(authorWebsite)\nCap Height: \(capHeight)\nLicence: \(licence.rawValue)\nFont File:\n\n<Attach Font File Here>", isHTML: false)
                            scene.windows.first?.rootViewController?.presentedViewController?.present(composeVC, animated: true)
                        }
                    }
                    .disabled(fontName.isEmpty || authorName.isEmpty || capHeight.isEmpty)
                }
            }
        }
    }
}

struct FontSubmissionView_Previews: PreviewProvider {
    static var previews: some View {
        FontSubmissionView()
    }
}
