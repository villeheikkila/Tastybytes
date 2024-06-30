import MessageUI
import SwiftUI
import UIKit

public typealias SendMailCallback = ((Result<MFMailComposeResult, Error>) -> Void)?

public struct SendEmailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    @Binding var email: Email

    let callback: SendMailCallback

    public init(email: Binding<Email>, callback: SendMailCallback = nil) {
        _email = email
        self.callback = callback
    }

    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
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

        public func mailComposeController(_: MFMailComposeViewController,
                                          didFinishWith result: MFMailComposeResult,
                                          error: Error?)
        {
            if let error {
                callback?(.failure(error))
            } else {
                callback?(.success(result))
            }
            $presentation.wrappedValue.dismiss()
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(presentation: presentation, data: $email, callback: callback)
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<SendEmailView>)
        -> MFMailComposeViewController
    {
        let mvc = MFMailComposeViewController()
        mvc.mailComposeDelegate = context.coordinator
        mvc.setSubject(email.subject)
        mvc.setToRecipients([email.adress])
        mvc.setMessageBody(email.body, isHTML: false)
        mvc.accessibilityElementDidLoseFocus()
        return mvc
    }

    public func updateUIViewController(_: MFMailComposeViewController,
                                       context _: UIViewControllerRepresentableContext<SendEmailView>) {}

    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
}

public struct Email: Sendable {
    public init(adress: String, subject: String, body: String) {
        self.adress = adress
        self.subject = subject
        self.body = body
    }

    public init() {
        adress = ""
        subject = ""
        body = ""
    }

    let adress: String
    let subject: String
    let body: String
}
