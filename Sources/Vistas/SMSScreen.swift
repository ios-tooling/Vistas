//
//  SMSScreen.swift
//  Vistas
//
//  Created by Ben Gottlieb on 11/7/25.
//

#if os(iOS)

import SwiftUI
import MessageUI

public struct SMSScreen: View {
	@Environment(\.dismiss) private var dismiss
	@Binding var isPresented: Bool
	let recipients: [String]
	let messageBody: String

	public init(isPresented: Binding<Bool>, recipients: [String], messageBody: String) {
		_isPresented = isPresented
		self.recipients = recipients.filter { !$0.isEmpty }
		self.messageBody = messageBody
	}

	public var body: some View {
		if MFMessageComposeViewController.canSendText() {
			WrappedSMSController(isPresented: $isPresented, recipients: recipients, messageBody: messageBody)
		} else {
			smsNotAvailableView
		}
	}

	@ViewBuilder var smsNotAvailableView: some View {
		VStack {
			Spacer()
			ZStack {
				Image(systemName: "message")
					.font(.system(size: 40))
				Image(systemName: "circle.slash")
					.font(.system(size: 80))
					.foregroundStyle(.red)
			}
			Spacer()
			Text("Sorry, messaging is not available on this device.")
				.multilineTextAlignment(.center)
				.font(.headline)
			Spacer()
			Spacer()
			Button(action: {
				isPresented = false
				dismiss()
			}) {
				Text("Done")
			}
			.buttonStyle(.borderedProminent)
		}
		.padding()
		.frame(maxWidth: 300)
	}
}

struct WrappedSMSController: UIViewControllerRepresentable {
	@Binding var isPresented: Bool
	let recipients: [String]
	let messageBody: String

	func makeUIViewController(context: Context) -> MFMessageComposeViewController {
		let controller = MFMessageComposeViewController()
		controller.messageComposeDelegate = context.coordinator
		controller.recipients = recipients
		controller.body = messageBody
		return controller
	}

	func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
		uiViewController.recipients = recipients
		uiViewController.body = messageBody
	}

	func makeCoordinator() -> SMSComposerCoordinator {
		SMSComposerCoordinator(isPresented: $isPresented)
	}

	class SMSComposerCoordinator: NSObject, MFMessageComposeViewControllerDelegate {
		@Binding var isPresented: Bool

		init(isPresented: Binding<Bool>) {
			self._isPresented = isPresented
		}

		func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
			isPresented = false
		}
	}
}
#endif
