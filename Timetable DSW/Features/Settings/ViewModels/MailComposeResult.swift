//
//  MailComposeResult.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//


import SwiftUI
import MessageUI

enum MailComposeResult {
    case sent, saved, cancelled, failed(Error?)
}

struct MailComposerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MFMailComposeViewController

    let recipients: [String]
    let subject: String
    let body: String
    let onFinish: (MailComposeResult) -> Void

    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onFinish: (MailComposeResult) -> Void
        init(onFinish: @escaping (MailComposeResult) -> Void) {
            self.onFinish = onFinish
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            controller.dismiss(animated: true) {
                let mapped: MailComposeResult
                switch result {
                case .cancelled: mapped = .cancelled
                case .saved:     mapped = .saved
                case .sent:      mapped = .sent
                case .failed:    mapped = .failed(error)
                @unknown default: mapped = .failed(error)
                }
                self.onFinish(mapped)
            }
        }
    }
}
