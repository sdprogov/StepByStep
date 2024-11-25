//
//  LoginView.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import SwiftUI

/// LoginView
/// - TODO: Only 1 button, can add `TextViews` in the future so user can enter credentials
struct LoginView: View {

	@Injected(\.authStore) private var authStore: AuthStoreProtocol

	var body: some View {
		VStack {
			Spacer()

			Button(action: {
				/// Hardcoded credentials
				authStore.logIn(
					username: "user1@test.com", password: "Test123!")
			}) {
				Text("Sign In")
					.fontWeight(.bold)
					.foregroundColor(.white)
					.frame(maxWidth: .infinity)
					.padding()
					.background(Color.blue)
					.cornerRadius(10)
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(Color.blue, lineWidth: 2)
					)
			}
			.padding()

			Spacer()
		}
		.padding()
		.listenForViewContextChanges(viewContext: .init(viewName: "Login View"))
		.onAppear {
			authStore.checkForCredentials()
		}
	}
}

#Preview {
	NavigationStack {
		LoginView()
	}
}
