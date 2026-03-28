//
//  ProfileView.swift
//  Tomapo
//
//  Created by Sophia Moos on 27.03.2026.
//

internal import SwiftUI

struct ProfileView: View {
    @Binding var selectedTab: BottomBarSelectedTab
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject private var userStore: TomapoUserStore
    @EnvironmentObject private var historyStore: ScanHistoryStore
    @EnvironmentObject private var userMessageStore: TomapoUserMessageStore

    @State private var showEditProfile = false
    @State private var showDeleteHistoryAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var isLoadingProfile = false

    private var api: TomapoAPIService { .shared }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // Header
                header
                    .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 24)

                // User Card
                userCard
                    .padding(.horizontal, 16).padding(.bottom, 20)

                // Settings
                settingsSection
                    .padding(.horizontal, 16).padding(.bottom, 20)

                // Statistics
                statsSection
                    .padding(.horizontal, 16).padding(.bottom, 20)

                // Danger Zone
                dangerSection
                    .padding(.horizontal, 16).padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet()
                .environmentObject(userStore)
        }
        .alert("Delete Scan History", isPresented: $showDeleteHistoryAlert) {
            Button("Delete", role: .destructive) {
                historyStore.clearAll()
                Task { try? await api.clearMyScanHistory() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All \(historyStore.entries.count) scanned products will be permanently deleted.")
        }
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Delete Account", role: .destructive) {
                Task {
                    try? await api.deleteMyAccount()
                    userStore.deleteUser()
                    historyStore.clearAll()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your account and all locally stored data will be deleted. This action cannot be undone.")
        }
        .task { await loadProfile() }
    }

    private func loadProfile() async {
        isLoadingProfile = true
        defer { isLoadingProfile = false }
        do {
            let profile = try await api.getMyProfile()
            userStore.updateUser(
                fullName: profile.fullName,
                email: profile.email,
                nickname: profile.nickname,
                avatarUrl: profile.avatarUrl
            )
        } catch {
            // Silent — use local data
        }
    }

    // MARK: - Header

    private var header: some View {
        Text("Profile")
            .font(.largeTitle).fontWeight(.heavy)
            .foregroundColor(Color.theme.cardFg)
    }

    // MARK: - User Card

    private var userCard: some View {
        VStack(spacing: 0) {
            // Illustration
            Image("IllusytrationHouse")
                .resizable().scaledToFit()
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .padding(.top, 12).padding(.bottom, 8)

            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.theme.mutedBg)
                        .frame(width: 64, height: 64)
                    if let user = userStore.currentUser {
                        Text(user.initials)
                            .font(.title2.weight(.bold))
                            .foregroundColor(Color.theme.accentFg)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color.theme.accentFg)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    if let user = userStore.currentUser {
                        Text(user.fullName)
                            .font(.title3.weight(.bold)).foregroundColor(Color.theme.cardFg)
                        Text("@\(user.nickname)")
                            .font(.subheadline).foregroundColor(Color.theme.mutedFg)
                        Text(user.email)
                            .font(.caption).foregroundColor(Color.theme.mutedFg)
                    } else {
                        Text("No Profile")
                            .font(.title3.weight(.bold)).foregroundColor(Color.theme.cardFg)
                        Text("Tap to create your profile")
                            .font(.caption).foregroundColor(Color.theme.mutedFg)
                    }
                }
                Spacer()
                Button { showEditProfile = true } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color.theme.accentFg.opacity(0.8))
                }
            }
            .padding(16)
        }
        .background(Color.theme.cardBg)
        .cornerRadius(16)
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Settings")
            VStack(spacing: 0) {
                // Dark Mode Toggle
                HStack {
                    Label("Theme Mode", systemImage: "moon.fill")
                        .font(.subheadline).foregroundColor(Color.theme.cardFg)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { themeManager.currentScheme == .dark },
                        set: { _ in themeManager.toggleTheme() }
                    ))
                    .tint(Color.theme.accentFg)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)

                Divider().padding(.leading, 16)

                // Notifications
                HStack {
                    Label("Notifications", systemImage: "bell.fill")
                        .font(.subheadline).foregroundColor(Color.theme.cardFg)
                    Spacer()
                    Text("Coming soon")
                        .font(.caption).foregroundColor(Color.theme.mutedFg)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)

                Divider().padding(.leading, 16)
                Button {
                    Task { try? await api.logout() }
                } label: {
                    HStack {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.subheadline).foregroundColor(Color.theme.warning)
                        Spacer()
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
            .background(Color.theme.cardBg)
            .cornerRadius(14)
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("My Statistics")
            HStack(spacing: 12) {
                StatCard(
                    value: "\(historyStore.entries.count)",
                    label: "Scanned Products",
                    icon: "barcode.viewfinder",
                    color: Color.theme.accentFg
                )
                StatCard(
                    value: "\(userMessageStore.messages.count)",
                    label: "Reports",
                    icon: "exclamationmark.bubble.fill",
                    color: Color.theme.accentFg
                )
                if historyStore.totalCo2KgPerKg > 0 {
                    StatCard(
                        value: String(format: "%.1f", historyStore.totalCo2KgPerKg),
                        label: "kg CO\u{2082} total",
                        icon: "leaf.fill",
                        color: Color.theme.success
                    )
                }
            }
        }
    }

    // MARK: - Danger Section

    private var dangerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Data")
            VStack(spacing: 0) {
                Button {
                    showDeleteHistoryAlert = true
                } label: {
                    HStack {
                        Label("Delete Scan History", systemImage: "trash")
                            .font(.subheadline).foregroundColor(Color.theme.warning)
                        Spacer()
                        Text("\(historyStore.entries.count) entries")
                            .font(.caption).foregroundColor(Color.theme.mutedFg)
                        Image(systemName: "chevron.right")
                            .font(.caption2).foregroundColor(Color.theme.mutedFg.opacity(0.35))
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 16)

                Button {
                    showDeleteAccountAlert = true
                } label: {
                    HStack {
                        Label("Delete Account & Data", systemImage: "person.crop.circle.badge.minus")
                            .font(.subheadline).foregroundColor(Color.theme.error)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2).foregroundColor(Color.theme.mutedFg.opacity(0.35))
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
            .background(Color.theme.cardBg)
            .cornerRadius(14)
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundColor(Color.theme.mutedFg)
            .tracking(0.5)
            .padding(.horizontal, 4)
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let value: String; let label: String; let icon: String; let color: Color
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 20)).foregroundColor(color)
            Text(value).font(.title3.weight(.bold)).foregroundColor(Color.theme.cardFg)
            Text(label).font(.caption2).foregroundColor(Color.theme.mutedFg)
                .multilineTextAlignment(.center).lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.theme.cardBg)
        .cornerRadius(12)
    }
}

// MARK: - Login Sheet (kept for future use)

private struct LoginSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var nickname = ""
    @State private var isRegister = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                if isRegister {
                    Section("Account") {
                        TextField("Full Name", text: $fullName)
                            .textContentType(.name)
                        TextField("Nickname", text: $nickname)
                            .textContentType(.username)
                            .autocapitalization(.none)
                    }
                }
                Section("Credentials") {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                        .textContentType(isRegister ? .newPassword : .password)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.caption).foregroundColor(Color.theme.error)
                    }
                }

                Section {
                    Button {
                        Task { await authenticate() }
                    } label: {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(isRegister ? "Create Account" : "Sign In")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .listRowBackground(Color.theme.accentFg)
                    .foregroundColor(.white)

                    Button {
                        withAnimation { isRegister.toggle() }
                    } label: {
                        Text(isRegister ? "Already have an account? Sign in" : "Don't have an account? Register")
                            .font(.caption).foregroundColor(Color.theme.accentFg)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle(isRegister ? "Register" : "Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func authenticate() async {
        isLoading = true
        errorMessage = nil
        do {
            if isRegister {
                _ = try await TomapoAPIService.shared.register(
                    fullName: fullName, email: email,
                    nickname: nickname.isEmpty ? email.components(separatedBy: "@").first ?? "user" : nickname,
                    password: password
                )
            } else {
                _ = try await TomapoAPIService.shared.login(email: email, password: password)
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Edit Profile Sheet

private struct EditProfileSheet: View {
    @EnvironmentObject private var userStore: TomapoUserStore
    @Environment(\.dismiss) private var dismiss

    @State private var fullName:  String = ""
    @State private var nickname:  String = ""
    @State private var email:     String = ""
    @State private var password:  String = ""
    @State private var confirmPassword: String = ""
    @State private var passwordError: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Your Name", text: $fullName)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.theme.cardFg)
                    }
                    HStack {
                        Text("Nickname")
                        Spacer()
                        TextField("@nickname", text: $nickname)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.theme.cardFg)
                    }
                    HStack {
                        Text("Email")
                        Spacer()
                        TextField("your@email.com", text: $email)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.theme.cardFg)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                }

                Section("Password") {
                    SecureField("New Password", text: $password)
                        .foregroundColor(Color.theme.cardFg)
                    SecureField("Confirm Password", text: $confirmPassword)
                        .foregroundColor(Color.theme.cardFg)
                    if passwordError {
                        Text("Passwords do not match")
                            .font(.caption).foregroundColor(Color.theme.error)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        // Validate passwords match if entered
                        if !password.isEmpty && password != confirmPassword {
                            passwordError = true
                            return
                        }
                        passwordError = false
                        let pwHash = password.isEmpty ? nil : password

                        if userStore.currentUser == nil {
                            userStore.createUser(
                                fullName: fullName.isEmpty ? "Anonymous" : fullName,
                                email: email, nickname: nickname.isEmpty ? "user" : nickname,
                                passwordHash: pwHash)
                        } else {
                            userStore.updateUser(
                                fullName: fullName.isEmpty ? nil : fullName,
                                email: email.isEmpty ? nil : email,
                                nickname: nickname.isEmpty ? nil : nickname,
                                passwordHash: pwHash)
                        }

                        // Sync to server
                        Task {
                            try? await TomapoAPIService.shared.updateMyProfile(
                                fullName: fullName.isEmpty ? nil : fullName,
                                nickname: nickname.isEmpty ? nil : nickname
                            )
                        }
                        dismiss()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.theme.accentFg)
                }
            }
        }
        .onAppear {
            if let user = userStore.currentUser {
                fullName = user.fullName
                nickname = user.nickname
                email    = user.email
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView(selectedTab: .constant(.profile))
        .environmentObject(ThemeManager())
        .environmentObject(TomapoUserStore())
        .environmentObject(ScanHistoryStore())
        .environmentObject(TomapoUserMessageStore())
        .background(Color.theme.cardBg)
}
