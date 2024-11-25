//
//  AuthStore.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import SwiftUI
import SwiftData

@main
struct StepByStepApp: App {

	@Injected(\.environment) var appEnvironment: AppEnvironment

    var body: some Scene {

        WindowGroup {
			if appEnvironment.user != nil {
				HomeView()
			} else {
				LoginView()
			}
        }
		.modelContainer(for: [
			StepRecord.self
		])
    }
}
