//
//  UserIdentity.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation

/// A model representing a logged in user
/// Probably no need to store the password, very least should be encrypted for security purposes
struct UserIdentity: Equatable {
	let username: String
	let password: String
	let token: String
}
