//
//  MailScreen.swift
//  Vistas
//
//  Created by Ben Gottlieb on 9/27/24.
//

import SwiftUI
import MessageUI

public struct MailScreen: View {
	@Environment(\.dismiss) private var dismiss
	
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
	
	public var body: some View {
		#if os(iOS)
			if MFMailComposeViewController.canSendMail() {
				WrappedMailController(toRecipients: toRecipients, subject: subject, bccRecipients: bccRecipients, content: content, isHTML: isHTML, attachments: attachments, didFinish: didFinish)
			} else {
				mailNotAvailableView
			}
		#else
			mailNotAvailableView
		#endif
	}
	
	@ViewBuilder var mailNotAvailableView: some View {
		VStack {
			Spacer()
			ZStack {
				Image(systemName: "envelope")
					.font(.system(size: 40))
				Image(systemName: "circle.slash")
					.font(.system(size: 80))
					.foregroundStyle(.red)
			}
			Spacer()
			Text("Sorry, no email account is configured on this device.")
				.multilineTextAlignment(.center)
				.font(.headline)
			Spacer()
			Spacer()
			Button(action: { dismiss() }) {
				Text("Done")
			}
			.buttonStyle(.borderedProminent)
		}
		.padding()
		.frame(maxWidth: 300)
	}
}

extension MailScreen {
	public struct MailAttachment: Equatable, Hashable {
		public let data: Data
		public let mimeType: String
		public let filename: String
		
		public init(data: Data, mimeType: String = "public.data", filename: String) {
			self.data = data
			self.mimeType = mimeType
			self.filename = filename
		}
	}
}
