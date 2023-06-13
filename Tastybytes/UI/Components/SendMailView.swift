import MessageUI
import SwiftUI
import UIKit

typealias SendMailCallback = ((Result<MFMailComposeResult, Error>) -> Void)?

struct SendEmailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    @Binding var email: Email

    let callback: SendMailCallback

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode
        @Binding var data: Email

        let callback: SendMailCallback

        init(presentation: Binding<PresentationMode>,
             data: Binding<Email>,
             callback: SendMailCallback)
        {
            _presentation = presentation
            _data = data
            self.callback = callback
        }

        func mailComposeController(_: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?)
        {
            if let error = error {
                callback?(.failure(error))
            } else {
                callback?(.success(result))
            }
            $presentation.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(presentation: presentation, data: $email, callback: callback)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<SendEmailView>)
    -> MFMailComposeViewController {
        let mvc = MFMailComposeViewController()
        mvc.mailComposeDelegate = context.coordinator
        mvc.setSubject(email.subject)
        mvc.setToRecipients([email.adress])
        mvc.setMessageBody(email.body, isHTML: false)
        mvc.accessibilityElementDidLoseFocus()
        return mvc
    }

    func updateUIViewController(_: MFMailComposeViewController,
                                context _: UIViewControllerRepresentableContext<SendEmailView>) {}

    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
}

struct Email: Sendable {
    let adress: String
    let subject: String
    let body: String

    static let feedback = Email(adress: "contact@tastybytes.app",
                                subject: "Feedback for \(Config.appName)",
                                body: "")
}
