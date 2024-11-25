//
//  ViewModel.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation
import SwiftUI
import Observation

/// ViewModel which manages a ViewContext for displaying loading indicators and errors
@Observable
class ViewContextModel<T: UserFacingErrorProtocol> {

	var isLoading: Bool = false {
		didSet {
			updateViewContext()
		}
	}
	var error: T? = nil {
		didSet {
			updateViewContext()
		}
	}

	private let viewContextId: UUID?

	private func updateViewContext() {
		@Injected(\.environment) var appEnvironment: AppEnvironment
		guard let viewContextId = viewContextId else { return }

		appEnvironment.setIsLoading(isLoading, for: viewContextId)
		appEnvironment.setError(error, for: viewContextId)
	}

	public init() {
		@Injected(\.environment) var appEnvironment: AppEnvironment
		viewContextId = appEnvironment.activeViewContext?.id
	}
}

/// `ViewContext`
/// For a given `View` defines `isLoading` and if a `blocingError` should be presented to the User
/// Provides the `View Name`
@Observable
class ViewContext: Identifiable {
	var isLoading: Bool = false
	var blockingError: UserFacingError? = nil

	let id: UUID
	let viewName: String

	public init(id: UUID = UUID(), viewName: String) {
		self.id = id
		self.viewName = viewName
	}
}

protocol UserFacingErrorProtocol: Error, Identifiable, Equatable {
	var userFacingMessage: String { get }
}

/// A `UserFacingError`
/// Provides a User Friendly error string
/// - TODO for brevity, some of the strings come directly from the API or `JSONDecoder` or `HKHealthStore` this should be removed in the future
struct UserFacingError: UserFacingErrorProtocol {

	let userFacingMessage: String

	let id: String = UUID().uuidString

	public init(error: any UserFacingErrorProtocol) {
		userFacingMessage = error.userFacingMessage
	}
}
