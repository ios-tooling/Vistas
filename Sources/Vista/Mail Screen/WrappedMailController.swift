//
//  WrappedMailController.swift
//  Vistas
//
//  Created by Ben Gottlieb on 7/21/24.
//

#if os(iOS)

import SwiftUI
import MessageUI

public struct WrappedMailController: UIViewControllerRepresentable {
	let attachments: [MailScreen.MailAttachment]
	let toRecipients: [String]?
	let subject: String?
	let bccRecipients: [String]?
	let content: String?
	let isHTML: Bool
	let didFinish: (@MainActor (Bool) -> Void)?

	public init(toRecipients: [String]?, subject: String?, bccRecipients: [String]? = nil, content: String? = nil, isHTML: Bool = false, attachments: [MailScreen.MailAttachment] = [], didFinish: (@MainActor (Bool) -> Void)? = nil) {
		self.bccRecipients = bccRecipients
		self.subject = subject
		self.toRecipients = toRecipients
		self.content = content
		self.isHTML = isHTML
		self.attachments = attachments
		self.didFinish = didFinish
	}
	
	public func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
		if let subject { context.coordinator.controller.setSubject(subject) }
		context.coordinator.didFinish = didFinish
		context.coordinator.controller.setToRecipients(toRecipients)
		context.coordinator.controller.setBccRecipients(bccRecipients)
		if let content { context.coordinator.controller.setMessageBody(content, isHTML: isHTML)}
		context.coordinator.addAttachments(attachments)
	}
	
	
	public func makeUIViewController(context: Context) -> MFMailComposeViewController {
		updateUIViewController(context.coordinator.controller, context: context)
		return context.coordinator.controller
	}
	public func makeCoordinator() -> Coordinator {
		Coordinator()
	}
	
	public class Coordinator: NSObject, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {
		let controller = MFMailComposeViewController()
		var didFinish: (@MainActor (Bool) -> Void)?
		var addedAttachments: [MailScreen.MailAttachment] = []

		func addAttachments(_ attachments: [MailScreen.MailAttachment]) {
			for attachment in attachments {
				if !addedAttachments.contains(attachment) {
					controller.addAttachmentData(attachment.data, mimeType: attachment.mimeType, fileName: attachment.filename)
					addedAttachments.append(attachment)
				}
			}
		}
		
		override init() {
			super.init()
			
			controller.mailComposeDelegate = self
		}
		
		public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
			controller.dismiss(animated: true, completion: nil)
			controller.mailComposeDelegate = nil
			if let didFinish {
				Task { @MainActor in
					didFinish(result == .sent)
				}
			}
		}
	}
}

#endif
