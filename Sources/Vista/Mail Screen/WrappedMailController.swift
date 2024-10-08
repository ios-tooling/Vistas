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
	let didFinish: ((Bool) -> Void)?
	
	public init(toRecipients: [String]?, subject: String?, bccRecipients: [String]? = nil, content: String? = nil, isHTML: Bool = false, attachments: [MailScreen.MailAttachment] = [], didFinish: ((Bool) -> Void)? = nil) {
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
		if let subject { context.coordinator.controller.setSubject(subject) }
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
		var didFinish: ((Bool) -> Void)?
		var addedAttachments: [Int] = []
		
		func addAttachments(_ attachments: [MailScreen.MailAttachment]) {
			for attachment in attachments {
				let hash = attachment.hashValue
				if !addedAttachments.contains(hash) {
					controller.addAttachmentData(attachment.data, mimeType: attachment.mimeType, fileName: attachment.filename)
					addedAttachments.append(hash)
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
			didFinish?(result == .sent)
		}
	}
}

#endif
