//
//  URLRequest+Extensions.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation

/// extensds `HTTPURLResponse` to standardize what `statusCode` means successful
extension HTTPURLResponse {
	enum Response {
		case isSuccessfull(statusCode: Int)
		case hasError(statusCode: Int)
	}
	/// Only `status codes` between 200 and 299 are considered a success
	var response: Response {
		if (200...299).contains(self.statusCode) {
			return .isSuccessfull(statusCode: self.statusCode)
		} else {
			return .hasError(statusCode: self.statusCode)
		}
	}
}

extension URLRequest {
	/// creates a `URLRequest` to upload `StepData`
	/// - Parameter stepData: `StepData` which is uploaded to the server
	/// - Returns a `URLRequest`
	/// - Note Was getting a 500 server error so was never able to upload any `StepData`, perhaps this is a backend error or poor error response
	static func uploadStepsRequest(with stepData: StepData) throws(StepsUploaderError) -> URLRequest {
		@Injected(\.environment) var appEnvironment: AppEnvironment

		guard let user = appEnvironment.user else {
			throw .userNotLoggedIn
		}

		var request = URLRequest(url: appEnvironment.apiBaseURL.appendingPathComponent("steps"))
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("Bearer \(user.token)", forHTTPHeaderField: "Authorization")

		do {
			let jsonData = try JSONEncoder().encode(stepData)
			request.httpBody = jsonData

			return request
		} catch {
			throw .encodingError(response: error.localizedDescription)
		}

	}
	
	/// creates an `URLRequest` that fetches `StepData` from the API
	/// - Returns a `URLRequest`
	static func fetchStepsHistoryRequest() throws(StepsFetchError) -> URLRequest {
		@Injected(\.environment) var appEnvironment: AppEnvironment

		guard let user = appEnvironment.user else {
			throw .userNotLoggedIn
		}

		var request = URLRequest(url: appEnvironment.apiBaseURL.appendingPathComponent("steps"))
		request.httpMethod = "GET"
		request.setValue("Bearer \(user.token)", forHTTPHeaderField: "Authorization")

		return request
	}
	
	/// creates an `URLRequest` that passes user credentials and gets back a token
	/// - Parameters:
	///   - userName: `String`
	///   - password: `String`
	/// - Returns
	///   - `URLRequest`
	static func loginRequest(userName: String, password: String) throws(AuthStateError) -> URLRequest {
		@Injected(\.environment) var appEnvironment: AppEnvironment

		let credentials: [String: Any] = [
			"identifier": userName,
			"password": password
		]

		// Convert credentials to JSON data
		guard let jsonData = try? JSONSerialization.data(withJSONObject: credentials) else {
			throw .loginFailed(message: "Error: Unable to convert credentials to JSON data")
		}

		var request = URLRequest(url: appEnvironment.apiBaseURL.appendingPathComponent("auth/local"))
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData

		return request
	}
}
