//
//  BaseViewModifier.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import SwiftUI
import Observation

///  Custom View Modifier that makes a View have a Context that can listen for errors and loading states from the `ViewModel`
///  Will automatically make the `View` apply `LoadingViewModifier` and `AlertModifier`
struct BaseViewModifier: ViewModifier {
	@Injected(\.environment) var appEnvironment: AppEnvironment

	@State var context: ViewContext

	init(viewContext: ViewContext) {
		self.context = viewContext
	}

	func body(content: Content) -> some View {
		ZStack {
			content
				.disabled(context.isLoading) // Disable interaction when loading
				.loadingIndicator(isLoading: $context.isLoading)
				.alert(for: $context.blockingError)

			if context.isLoading {
				Color.black.opacity(0.4) // Optional: Background overlay
					.edgesIgnoringSafeArea(.all)

				VStack {
					ProgressView()
						.progressViewStyle(CircularProgressViewStyle(tint: .white))
						.scaleEffect(2) // Scale the indicator
					Text("Loading...")
						.font(.headline)
						.foregroundColor(.white)
				}
			}
		}
		.onAppear {
			self.appEnvironment.activeViewContext = context
		}
	}
}
