//
//  AuthStore.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation
import Observation
import Combine

enum AuthState {
	case unauthenticated
	case authenticated(user: UserIdentity)
}

enum AuthStateError: UserFacingErrorProtocol {
	var userFacingMessage: String {
		switch self {
		case .loginFailed(let message):
			return "Login failed with \(message)"
		}
	}

	var id: String { userFacingMessage }

	case loginFailed(message: String)
}

/// A protocol for defining what a `AuthStore` will do
protocol AuthStoreProtocol {
	var state: AuthState { get }
	var error: AuthStateError? { get }

	func logIn(username: String, password: String)
	func checkForCredentials()
}

/// The `MockAuthStore`, does not connect to the `API` nor does it save credentials to the `Keychain`
@Observable
class MockAuthStore: ViewContextModel<AuthStateError>, AuthStoreProtocol {
	var state: AuthState = .unauthenticated

	private var keychainHelper: KeychainHelperProtocol.Type

	
	/// Public initializer
	/// - Parameter keychain: `KeychainHelperProtocol`, in this automatically passes in the `MockKeychainHelper`
	/// Could be refactored to prevent the actual `KeychainHelper` from being passed in
	public init(keychain: KeychainHelperProtocol.Type = MockKeychainHelper.self) {
		self.keychainHelper = keychain
	}

	func checkForCredentials() {
		// No - OP
	}
	
	/// Logs User In
	/// - Parameters:
	///   - username: `String`
	///   - password: `String`
	///   Will wait for `10` seconds before fetching mock credentials from the `KeychainHelper`
	///   Note, if `MockAuthStore` was overriden to pass in the actual `KeychainHelper`, this will never work
	func logIn(username: String = "user1@test.com", password: String = "Test123!") {
		@Injected(\.environment) var appEnvironment: AppEnvironment
		isLoading = true
		Task { @MainActor [unowned self] in
			try? await Task.sleep(for: .seconds(10))
			if let user = self.keychainHelper.loadUserCredentials() {
				self.state = .authenticated(user: user)
				appEnvironment.user = user
				isLoading = false
			} else {
				self.error = .loginFailed(message: "Mock cannot load user credentials")
				isLoading = false
			}
		}
	}
}

/// The `AuthStore` that fetches user credentials from the `API` and stores them in the Keychain for automatic log in
@Observable
class AuthStore: ViewContextModel<AuthStateError>, AuthStoreProtocol {

	var state: AuthState = .unauthenticated

	private var cancellables = Set<AnyCancellable>()

	private var keychainHelper: KeychainHelperProtocol.Type
	
	/// Public Initializer
	/// - Parameter keychain: `KeychainHelperProtocol` defaults to `KeychainHelper`
	/// Should be refactored to not allow the `MockKeychainHelper` from being passed in
	public init(keychain: KeychainHelperProtocol.Type = KeychainHelper.self) {
		self.keychainHelper = keychain
		super.init()
	}
	
	/// Checks for saved user credentials by consulting the `KeychainHelper`
	func checkForCredentials() {
		@Injected(\.environment) var appEnvironment: AppEnvironment
		if let user = keychainHelper.loadUserCredentials() {
			state = .authenticated(user: user)
			appEnvironment.user = user
		}
	}

	/// Fetches token from API
	/// - Parameters:
	///   - username: `String`
	///   - password: `String`
	private func authenticate(username: String, password: String) async throws(AuthStateError) -> UserIdentity {
		@Injected(\.environment) var appEnvironment: AppEnvironment

		let request = try URLRequest.loginRequest(userName: username, password: password)

		do {
			let (data, response) = try await URLSession.shared.data(for: request)

			guard let httpResponse = response as? HTTPURLResponse, case .isSuccessfull(_) = httpResponse.response else {
				let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
				throw AuthStateError.loginFailed(message: "Login failed with status code \(statusCode)")
			}

			do {
				if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
				   let token = json["jwt"] as? String {
					return UserIdentity(username: username, password: password, token: token)
				} else {
					throw AuthStateError.loginFailed(message: "Missing token")
				}
			} catch {
				throw AuthStateError.loginFailed(message: error.localizedDescription)
			}

		} catch {
			throw .loginFailed(message: error.localizedDescription)
		}
	}

	/// Logs user in
	/// - Parameters:
	///   - username: `String`
	///   - password: `String`
	///   Fetches token and saves to the `Keychain`
	///   Default credentials are currently passed in since Log In screen does not have `TextViews` for user to input credentials
	func logIn(username: String = "user1@test.com", password: String = "Test123!") {
		@Injected(\.environment) var appEnvironment: AppEnvironment
		isLoading = true

		Task { @MainActor [unowned self] in
			do throws(AuthStateError) {
				let user = try await authenticate(username: username, password: password)
				appEnvironment.user = user
				self.state = .authenticated(user: user)
				self.keychainHelper.saveUserCredentials(user)
				self.isLoading = false
			} catch {
				self.error = error
				self.isLoading = false
			}
		}
	}
}

/// Makes the `AuthStore` injectable
private struct AuthStoreProviderKey: InjectionKey {
	static var currentValue: AuthStoreProtocol = StepsAppContext.shared.appAuthStore

}

extension InjectedValues {
	var authStore: AuthStoreProtocol {
		get { Self[AuthStoreProviderKey.self] }
		set { Self[AuthStoreProviderKey.self] = newValue }
	}
}

