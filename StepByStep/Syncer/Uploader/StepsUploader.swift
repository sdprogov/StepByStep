//
//  StepsUploader.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation

enum StepsUploaderError {
	case userNotLoggedIn
	case encodingError(response: String)
	case badURL(url: String)
	case badRequest(error: String)
	case serverError(response: String)
}

extension StepsUploaderError: UserFacingErrorProtocol {
	var userFacingMessage: String {
		switch self {
		case .userNotLoggedIn:
			"Could not upload steps as user is no longer logged in"
		case .encodingError(response: let response):
			"Encoding the data failed due to \(response)"
		case .badURL(url: let url):
			"Uploading failed due to malformed URL: \(url)"
		case .badRequest(error: let error):
			"Request is bad: \(error)"
		case .serverError(response: let response):
			"Server returned a error: \(response)"
		}
	}
	
	var id: String {
		userFacingMessage
	}
	

}

/// Protocol defining a `StepsUploader` must preform
protocol StepsUploadable {
	func uploadStepData(stepData: StepData) async throws(StepsUploaderError)
}

/// A `MockStepsUploader` which merely does nothing
class MockStepsUploader: StepsUploadable {

	func uploadStepData(stepData: StepData) async throws(StepsUploaderError) {
		print("[UPLOADING]: \(stepData)")
	}
}

/// `StepsUploader` which uploads `StepData` to API
/// - Note I was getting a 500 error from the API, since this error was not more descriptive I did not debug further
/// - TODO: debug API more
class StepsUploader: StepsUploadable {

	func uploadStepData(stepData: StepData) async throws(StepsUploaderError) {
		let request = try URLRequest.uploadStepsRequest(with: stepData)

		do {
			let (data, response) = try await URLSession.shared.data(for: request)

			guard let httpResponse = response as? HTTPURLResponse, case .isSuccessfull(_) = httpResponse.response else {
				let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
				let reason = "\(statusCode) \(String(decoding: data, as: Unicode.UTF8.self))"
				throw StepsUploaderError.serverError(response: reason)
			}
		} catch {
			throw StepsUploaderError.badRequest(error: error.localizedDescription)
		}
	}
}
