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
    static let defaultAccessToken  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY0YTFiMmMzZDRlNWY2YTdiOGM5ZDAwMSIsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNzc0Njc3NTk5LCJleHAiOjE3NzQ2OTU1OTl9.MTA6k3OqYgi0CYB-j7hL6LTTHj8NHE4cXAtEJStCJyU"
    static let defaultRefreshToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY0YTFiMmMzZDRlNWY2YTdiOGM5ZDAwMSIsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNzc0Njc3NTk5LCJleHAiOjE3NzcyNjk1OTl9.aXtGfD2zmoUyA9UeJ4-cbsy6Z8vvQRiBEP6xfYcoU20"
    static let defaultUserId       = "64a1b2c3d4e5f6a7b8c9d001"
}
