//
//  StepsFetcher.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation

/// Protocol defining a `StepsFetcher` must preform
protocol StepsFetchable {
	func fetchSteps() async throws(StepsFetchError) -> [StepData]
}

enum StepsFetchError {
	case userNotLoggedIn
	case decodeError(response: String)
	case badURL(url: String)
	case badRequest(error: String)
	case serverError(response: String)
	case unknown(error: String)
}

extension StepsFetchError: UserFacingErrorProtocol {
	var userFacingMessage: String {
		switch self {
		case .userNotLoggedIn:
			return "Fetching steps failed because user is no longer logged in"
		case .decodeError(response: let response):
			return "Decoding server response failed, the response: \(response)"
		case .badURL(url: let url):
			return "URL is malformed: \(url)"
		case .badRequest(error: let error):
			return "Request failed with error: \(error)"
		case .serverError(response: let response):
			return "Server returned a error: \(response)"
		case .unknown(error: let error):
			return "Fetching history failed with: \(error)"
		}
	}
	
	var id: String {
		return userFacingMessage
	}
}

/// A `MockStepsFetcher` that uses mock generated data
class MockStepsFetcher: StepsFetchable {
	var mockSteps: [StepData] = []

	init(mockSteps: [StepData] = []) {
		self.mockSteps = mockSteps
	}

	func fetchSteps() async throws(StepsFetchError) -> [StepData] {
		self.mockSteps = [StepData].generateMockData(count: 30)
		return mockSteps
	}
}

/// `StepsFetcher` that fetches data from the API
class StepsFetcher: StepsFetchable {

	func fetchSteps() async throws(StepsFetchError) -> [StepData] {
		let request = try URLRequest.fetchStepsHistoryRequest()

		do {
			let (data, response) = try await URLSession.shared.data(for: request)

			guard let httpResponse = response as? HTTPURLResponse, case .isSuccessfull(_) = httpResponse.response else {
				throw StepsFetchError.serverError(response: response.description)
			}

			do {
				let steps = try JSONDecoder().decode([StepData].self, from: data)
				return steps
			} catch {
				throw StepsFetchError.decodeError(response: error.localizedDescription)
			}
			
		} catch {
			throw .badRequest(error: error.localizedDescription)
		}
	}
}


