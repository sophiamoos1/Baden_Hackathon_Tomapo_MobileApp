//
//  TomapoAPIConfig.swift
//  Tomapo
//
//  API configuration constants for the Tomapo backend.
//

internal import Foundation

enum TomapoAPIConfig {
    static let baseURL = "http://localhost:3000/api/v1"
    static let intelligenceBaseURL = "http://localhost:3000"

    // @AppStorage keys
    static let tokenAccessKey  = "tomapo_access_token"
    static let tokenRefreshKey = "tomapo_refresh_token"
    static let tokenUserIdKey  = "tomapo_user_id"

    // Default credentials — user is always pre-authenticated
    // MARK: Needed bc on the Simulator we can't scan code, and on the physical-device we can't reach localhost
    // TODO: If our Challenge wins, those are the first lines to be changed
    static let defaultAccessToken  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY0YTFiMmMzZDRlNWY2YTdiOGM5ZDAwMSIsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNzc0NjgxNDQwLCJleHAiOjE3NzQ2OTk0NDB9.x5Set0vW1Z-0AJS0SZQLGtW58ZJfK7mFF6eVToJr7BI"
    static let defaultRefreshToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY0YTFiMmMzZDRlNWY2YTdiOGM5ZDAwMSIsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNzc0NjgxNDQwLCJleHAiOjE3NzcyNzM0NDB9.Kgg7N1KHjIIK6txg3bEQfaOueIV649rTSz26MmcWviY"
    static let defaultUserId       = "64a1b2c3d4e5f6a7b8c9d001"
}
