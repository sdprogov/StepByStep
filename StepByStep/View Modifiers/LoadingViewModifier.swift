//
//  LoadingViewModifier.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation
import SwiftUI

/// A `ViewModifier` that presents a `ActivityIndicator` if `isLoading` is `true`
/// Also will disable the `View` from being UIInteractable while `isLoading` is `true`
/// - TODO make a custom `ActivityIndicator`
struct LoadingModifier: ViewModifier {
	@Binding var isLoading: Bool

	func body(content: Content) -> some View {
		ZStack {
			content
				.disabled(isLoading) // Disable interaction when loading

			if isLoading {
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
	}
}
