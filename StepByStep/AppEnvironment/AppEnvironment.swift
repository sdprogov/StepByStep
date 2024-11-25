//
//  AppEnvironment.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation
import SwiftUI
import Observation

/// An `@Observable` global Environment that `Views` can tap into
@Observable
class AppEnvironment {

	var user: UserIdentity?
	let configuration: AppAPIEnvironment

	var apiBaseURL: URL { configuration.baseURL }

	var activeViewContext: ViewContext?
	
	/// Func that will inform `ViewContext` if App is in a loading state
	/// - Parameters:
	///   - isLoading: `Bool` for if App is loading or not
	///   - viewContextId: `UUID` the app will check that the `activeViewContext` is the one listening
	func setIsLoading(_ isLoading: Bool, for viewContextId: UUID) {
		guard viewContextId == activeViewContext?.id else { return }
		activeViewContext?.isLoading = isLoading
	}
	
	/// Func that will inform `ViewContext` if App has an error state
	/// - Parameters:
	///   - error: any `UserFacingErrorProtocol`
	///   - viewContextId:`UUID` the app will check that the `activeViewContext` is the one listening
	func setError(_ error: (any UserFacingErrorProtocol)?, for viewContextId: UUID) {
		guard viewContextId == activeViewContext?.id else { return }
		if let error = error {
			activeViewContext?.blockingError = .init(error: error)
		} else {
			activeViewContext?.blockingError = nil
		}
	}

	init(apiEnvironment: AppAPIEnvironment) {
		configuration = apiEnvironment
	}
}

/// Makes the `AppEnvironment` injectable
private struct AppEnvironmentProviderKey: InjectionKey {
	static var currentValue: AppEnvironment = StepsAppContext.shared.appEnvironmentVariables
}

extension InjectedValues {
	var environment: AppEnvironment {
		get { Self[AppEnvironmentProviderKey.self] }
		set { Self[AppEnvironmentProviderKey.self] = newValue }
	}
}
