//
//  View+Extensions.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation
import SwiftUI

/// Handy extensions for quickly applying the following `View Modifiers`
extension View {
	func loadingIndicator(isLoading: Binding<Bool>) -> some View {
		self.modifier(LoadingModifier(isLoading: isLoading))
	}

	func alert<T: UserFacingErrorProtocol>(for error: Binding<T?>) -> some View {
		self.modifier(AlertModifier(error: error))
	}

	func listenForViewContextChanges(viewContext: ViewContext) -> some View {
		self.modifier(BaseViewModifier(viewContext: viewContext))
	}
}
