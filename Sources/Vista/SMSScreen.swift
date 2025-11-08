//
//  SMSScreen.swift
//  Vistas
//
//  Created by Ben Gottlieb on 11/7/25.
//

#if os(iOS)

import SwiftUI
import MessageUI

public struct SMSScreen: UIViewControllerRepresentable {
	@Binding var isPresented: Bool
	let recipients: [String]
	let messageBody: String
	
	public init(isPresented: Binding<Bool>, recipients: [String], messageBody: String) {
		_isPresented = isPresented
		self.recipients = recipients.filter { !$0.isEmpty }
		self.messageBody = messageBody
	}
	
	public func makeUIViewController(context: Context) -> MFMessageComposeViewController {
		let controller = MFMessageComposeViewController()
		controller.messageComposeDelegate = context.coordinator
		controller.recipients = recipients
		controller.body = messageBody
		return controller
	}
	
	public func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
		uiViewController.recipients = recipients
		uiViewController.body = messageBody
	}
	
	public func makeCoordinator() -> SMSComposerCoordinator {
		SMSComposerCoordinator(isPresented: $isPresented)
	}
	
	public class SMSComposerCoordinator: NSObject, MFMessageComposeViewControllerDelegate {
		@Binding var isPresented: Bool
		
		init(isPresented: Binding<Bool>) {
			self._isPresented = isPresented
		}
		
		public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
			isPresented = false
			// Handle message result here (sent, canceled, etc.)
		}
	}
}
#endif
