//
//  AppConfiguration.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation

/// API Environment, defaulting to the same `url` but this can be configured
enum AppAPIEnvironment {
	case development
	case production

	// Same for now
	var baseURL: URL {
		switch self {
		case .development: return .init(string: "https://testapi.mindware.us")!
		case .production: return .init(string: "https://testapi.mindware.us")!
		}
	}
}

/// Protocol for the App Configuration
protocol StepsAppConfigurable {
	var environment: AppEnvironment { get }
	var healthStore: HealthStoreProtocol { get }
	var authStore: AuthStoreProtocol { get }
	var stepsStore: StepsStoreProtocol { get }
}

/// Mock App Configuration, points to all mock environments + `development` for APIs
class MockStepsAppConfiguration: StepsAppConfigurable {
	var environment: AppEnvironment {
		AppEnvironment(apiEnvironment: .development)
	}
	var healthStore: HealthStoreProtocol { MockHealthStore() }
	var authStore: AuthStoreProtocol { MockAuthStore() }
	var stepsStore: StepsStoreProtocol { MockStepsStore() }
}

/// Live App Configuration, will write to Swift Data and hit the Login and Steps API, currently won't upload due to 500 server error for this endpoint.
class LiveStepsAppConfiguration: StepsAppConfigurable {
	var environment: AppEnvironment {
		AppEnvironment(apiEnvironment: .development)
	}
	var healthStore: HealthStoreProtocol { HealthStore() }
	var authStore: AuthStoreProtocol { AuthStore() }
	var stepsStore: StepsStoreProtocol { StepsStore() }
}

/// The Context which has a reference to the App Configuration
class StepsAppContext {

	static let shared = StepsAppContext()

	private let configuration: StepsAppConfigurable
	/// Checks the Scheme and loads either the Mock or Live Environment
	/// - `StepByStep` points to `DEBUG`
	/// - `StepByStepLIVE` points to `RELEASE`
	///  - For testing the app it's better to point to `DEBUG` as even APIs don't have current data.
	private init() {
		#if DEBUG
			configuration = MockStepsAppConfiguration()
		#else
			configuration = LiveStepsAppConfiguration()
		#endif
	}

	var appEnvironmentVariables: AppEnvironment {
		configuration.environment
	}

	var appHealthStore: HealthStoreProtocol {
		configuration.healthStore
	}

	var appAuthStore: AuthStoreProtocol {
		configuration.authStore
	}

	var appStepsStore: StepsStoreProtocol {
		configuration.stepsStore
	}

}
