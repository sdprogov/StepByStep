//
//  AlertModifier.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation
import SwiftUI

/// A `ViewModifier` that presents a `OS Alert` with message from `UserFacingErrorProtocol`
/// `OS Alert` is presented whenever `error` is not `nil`
/// - TODO create custom `Alert View` with more options than just `OK` and more descriptive titles
struct AlertModifier<T: UserFacingErrorProtocol>: ViewModifier {
	@Binding var error: T?

	func body(content: Content) -> some View {
		content
			.alert(item: $error) { error in
				Alert(title: Text("Error"),
					  message: Text(error.userFacingMessage),
					  dismissButton: .default(Text("OK")))
			}
	}
}
