//
//  Readme.md
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

# StepByStep App

This is my submission to the Sparq exercise challenge.

## Table of Contents
- [Features](#features)
- [Environment Schemes](#environment-schemes)
- [Syncer Functionality](#syncer-functionality)
- [Unit Tests](#unit-tests)
- [Installation](#installation)
- [Usage](#usage)

## Features
- Tracks user steps using HealthKit but also has a Mock Step Generator.
- Saves step data to SwiftData for persistence.
- Syncs data to a remote server.
- Supports multiple environments.

## Environment Schemes

The app supports two main schemes:

- **StepByStep (Mock Environment)**:
  - Use this scheme for local development and testing.
  - The app simulates HealthKit data for testing purposes without impacting real user data.
  - The app simulates data from the API without making any calls.
  - The app simulates a mock User so no call is made to the api.
  - The app does not store any data to the Keychain or SwiftData DB.

- **StepByStepLIVE (LIVE Environment)**:
  - Use this scheme for production builds.
  - The app accesses actual HealthKit data.
  - The app will make calls to the STEPS API and retrieve data. All data is outdated so nothing appears in the history (last 7 days/ 30 days).
  - For whatever reason, I was getting a 500 server error uploading so the syncer still uses a Mock uploader so one can test the storage of data.

### Switching Schemes
To switch between environments, select the desired scheme in Xcode before building the app.

## Syncer Functionality

The Syncer is responsible for:
- **Saving Steps from HealthKit**: It fetches step count data from HealthKit every 5 minutes.
- **Storing Data in SwiftData**: The Syncer saves the retrieved data into SwiftData for offline access.
- **Uploading Data**: Due to a 500 server error when uploading data, the syncer still uses the Mock uploader.

### Sync Process Overview
1. **Fetch Steps**: Retrieve steps from HealthKit.
2. **Save Locally**: Store the steps in SwiftData.
3. **Upload**: Send the data to the server. Currently not doing this due a 500 error.

## Unit Tests

Unit tests are implemented just as an example of how one would go about testing.
- **Data Decoding**: Tests decoding JSON into StepData.
- **Step Fetcher**: Tests StepsFetcher will throw an error when missing user credentials.

## Installation

To install the Steps app, clone the repository and open it in Xcode:
Make sure to select the appropriate scheme (StepByStep or StepByStepLIVE) before running the app.

## Usage

After installation, you can run the app on a physical device to test HealthKit integrations. Make sure to grant the app permission to access HealthKit data.


