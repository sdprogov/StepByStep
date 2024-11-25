//
//  KeychainHelper.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Security
import Foundation

/// Protocol defining the scope of the `KeychainHelper`
protocol KeychainHelperProtocol {
	static func loadUserCredentials() -> UserIdentity?
	static func saveUserCredentials(_ user: UserIdentity)
	static func removeUserCredentials()
}

/// Mock Keychain Helper
class MockKeychainHelper: KeychainHelperProtocol {
	static func loadUserCredentials() -> UserIdentity? { UserIdentity(username: "user1@test.com", password: "Test123!", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6OCwiaWF0IjoxNzMyMTM0MzkzLCJleHAiOjE3MzQ3MjYzOTN9.shu2H9GrmzwO0nWfs3gXmy85ZzfVRJ_LFOyW_Dz7L8E") }
	static func saveUserCredentials(_ user: UserIdentity) {}
	static func removeUserCredentials() {}
}

/// Live `Keychain` will store in the actual `Keychain` for security reasons
class KeychainHelper: KeychainHelperProtocol {

	enum Constants {
		static let usernameKey = "username"
		static let passwordKey = "password"
		static let tokenKey = "token"
	}

	static func loadUserCredentials() -> UserIdentity? {
		guard let retrievedUsernameData = KeychainHelper.load(key: Constants.usernameKey),
		   let retrievedUsername = String(data: retrievedUsernameData, encoding: .utf8) else {
			return nil
		}

		guard let retrievedPasswordData = KeychainHelper.load(key: Constants.passwordKey),
		   let retrievedPassword = String(data: retrievedPasswordData, encoding: .utf8) else {
			return nil
		}

		guard let retrievedTokenData = KeychainHelper.load(key: Constants.tokenKey),
		   let retrievedToken = String(data: retrievedTokenData, encoding: .utf8) else {
			return nil
		}

		return UserIdentity(username: retrievedUsername, password: retrievedPassword, token: retrievedToken)
	}

	static func saveUserCredentials(_ user: UserIdentity) {
		if let usernameData = user.username.data(using: .utf8) {
			_ = KeychainHelper.save(key: Constants.usernameKey, data: usernameData)
		}

		if let passwordData = user.password.data(using: .utf8) {
			_ = KeychainHelper.save(key: Constants.passwordKey, data: passwordData)
		}

		if let tokenData = user.token.data(using: .utf8) {
			_ = KeychainHelper.save(key: Constants.tokenKey, data: tokenData)
		}
	}

	static func removeUserCredentials() {
		_ = KeychainHelper.delete(key: Constants.passwordKey)
		_ = KeychainHelper.delete(key: Constants.tokenKey)
		_ = KeychainHelper.delete(key: Constants.usernameKey)
	}

	private static func save(key: String, data: Data) -> OSStatus {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecValueData as String: data
		]

		SecItemDelete(query as CFDictionary) // Delete any existing item
		return SecItemAdd(query as CFDictionary, nil)
	}

	private static func load(key: String) -> Data? {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecReturnData as String: kCFBooleanTrue!,
			kSecMatchLimit as String: kSecMatchLimitOne
		]

		var dataTypeRef: AnyObject? = nil
		let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

		if status == errSecSuccess {
			return dataTypeRef as? Data
		} else {
			return nil
		}
	}

	private static func delete(key: String) -> OSStatus {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key
		]

		return SecItemDelete(query as CFDictionary)
	}
}

