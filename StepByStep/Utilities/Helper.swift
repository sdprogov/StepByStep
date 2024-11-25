//
//  AuthStore.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation

/// Just used by `UI`
/// Defined here globally
/// TODO: abstract them into some `Enum`
func underHalfwayToGoal(_ count: Int) -> Bool {
    count < 5000
}

func isUnderGoal(_ count: Int) -> Bool {
	count < 10000
}
