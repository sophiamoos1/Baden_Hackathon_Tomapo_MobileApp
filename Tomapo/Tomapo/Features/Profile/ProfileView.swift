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
 
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
 
                // Header
                header
                    .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 24)
 
                // User Card
                userCard
                    .padding(.horizontal, 16).padding(.bottom, 20)
 
                // Einstellungen
                settingsSection
                    .padding(.horizontal, 16).padding(.bottom, 20)
 
                // Statistiken
                statsSection
                    .padding(.horizontal, 16).padding(.bottom, 20)
 
                // Gefahrenzone
                dangerSection
                    .padding(.horizontal, 16).padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet()
                .environmentObject(userStore)
        }
        .alert("Scan-History löschen", isPresented: $showDeleteHistoryAlert) {
            Button("Löschen", role: .destructive) { historyStore.clearAll() }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Alle \(historyStore.entries.count) gescannten Produkte werden unwiderruflich gelöscht.")
        }
        .alert("Account löschen", isPresented: $showDeleteAccountAlert) {
            Button("Account löschen", role: .destructive) {
                userStore.deleteUser()
                historyStore.clearAll()
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Dein Account und alle lokalen Daten werden gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.")
        }
    }
 
    // MARK: - Header
 
    private var header: some View {
        Text("Profil")
            .font(.largeTitle).fontWeight(.heavy)
            .foregroundColor(Color.theme.importantText)
    }
 
    // MARK: - User Card
 
    private var userCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.theme.softOliveFog.opacity(0.5))
                        .frame(width: 64, height: 64)
                    if let user = userStore.currentUser {
                        Text(user.initials)
                            .font(.title2.weight(.bold))
                            .foregroundColor(Color.theme.mutedSage)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color.theme.mutedSage)
                    }
                }
 
                VStack(alignment: .leading, spacing: 4) {
                    if let user = userStore.currentUser {
                        Text(user.fullName)
                            .font(.title3.weight(.bold)).foregroundColor(Color.theme.bodyText)
                        Text("@\(user.nickname)")
                            .font(.subheadline).foregroundColor(Color.theme.bodyText.opacity(0.6))
                        Text(user.email)
                            .font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.45))
                    } else {
                        Text("Kein Profil")
                            .font(.title3.weight(.bold)).foregroundColor(Color.theme.bodyText)
                        Text("Tippe um ein Profil zu erstellen")
                            .font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.5))
                    }
                }
                Spacer()
                Button { showEditProfile = true } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color.theme.mutedSage.opacity(0.8))
                }
            }
            .padding(16)
        }
        .background(Color.theme.oatMilk.opacity(0.85))
        .cornerRadius(16)
    }
 
    // MARK: - Settings Section
 
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Einstellungen")
            VStack(spacing: 0) {
                // Dark Mode Toggle
                HStack {
                    Label("Dark Mode", systemImage: "moon.fill")
                        .font(.subheadline).foregroundColor(Color.theme.bodyText)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { themeManager.currentScheme == .dark },
                        set: { _ in themeManager.toggleTheme() }
                    ))
                    .tint(Color.theme.mutedSage)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
 
                Divider().padding(.leading, 16)
 
                // Benachrichtigungen (Platzhalter)
                HStack {
                    Label("Benachrichtigungen", systemImage: "bell.fill")
                        .font(.subheadline).foregroundColor(Color.theme.bodyText)
                    Spacer()
                    Text("Bald verfügbar")
                        .font(.caption).foregroundColor(Color.theme.bodyText.opacity(0.4))
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
            }
            .background(Color.theme.oatMilk.opacity(0.85))
            .cornerRadius(14)
        }
    }
 
    // MARK: - Stats Section
 
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Meine Statistiken")
            HStack(spacing: 12) {
                StatCard(
                    value: "\(historyStore.entries.count)",
                    label: "Gescannte Produkte",
                    icon: "barcode.viewfinder",
                    color: Color.theme.mutedSage
                )
                StatCard(
                    value: "\(userMessageStore.messages.count)",
                    label: "Meldungen",
                    icon: "exclamationmark.bubble.fill",
                    color: Color.theme.accentTerracotta
                )
                if historyStore.totalCo2KgPerKg > 0 {
                    StatCard(
                        value: String(format: "%.1f", historyStore.totalCo2KgPerKg),
                        label: "kg CO₂ total",
                        icon: "leaf.fill",
                        color: .green
                    )
                }
            }
        }
    }
 
    // MARK: - Danger Section
 
    private var dangerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Daten")
            VStack(spacing: 0) {
                Button {
                    showDeleteHistoryAlert = true
                } label: {
                    HStack {
                        Label("Scan-History löschen", systemImage: "trash")
                            .font(.subheadline).foregroundColor(Color.theme.warning)
                        Spacer()
                        Text("\(historyStore.entries.count) Einträge")
                            .font(.caption).foregroundColor(Color.theme.oatMilk.opacity(0.5))
                        Image(systemName: "chevron.right")
                            .font(.caption2).foregroundColor(Color.theme.bodyText.opacity(0.3))
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                }
                .buttonStyle(.plain)
 
                Divider().padding(.leading, 16)
 
                Button {
                    showDeleteAccountAlert = true
                } label: {
                    HStack {
                        Label("Account & Daten löschen", systemImage: "person.crop.circle.badge.minus")
                            .font(.subheadline).foregroundColor(Color.theme.error)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2).foregroundColor(Color.theme.bodyText.opacity(0.3))
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
            .background(Color.theme.oatMilk.opacity(0.85))
            .cornerRadius(14)
        }
    }
 
    // MARK: - Helpers
 
    private func sectionLabel(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundColor(Color.theme.bodyText.opacity(0.5))
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
            Text(value).font(.title3.weight(.bold)).foregroundColor(Color.theme.bodyText)
            Text(label).font(.caption2).foregroundColor(Color.theme.bodyText.opacity(0.5))
                .multilineTextAlignment(.center).lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.theme.oatMilk.opacity(0.85))
        .cornerRadius(12)
    }
}
 
// MARK: - Edit Profile Sheet
 
private struct EditProfileSheet: View {
    @EnvironmentObject private var userStore: TomapoUserStore
    @Environment(\.dismiss) private var dismiss
 
    @State private var fullName:  String = ""
    @State private var nickname:  String = ""
    @State private var email:     String = ""
 
    var body: some View {
        NavigationStack {
            Form {
                Section("Profil") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Dein Name", text: $fullName)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.theme.bodyText)
                    }
                    HStack {
                        Text("Nickname")
                        Spacer()
                        TextField("@nickname", text: $nickname)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.theme.bodyText)
                    }
                    HStack {
                        Text("E-Mail")
                        Spacer()
                        TextField("deine@email.ch", text: $email)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.theme.bodyText)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                }
            }
            .navigationTitle("Profil bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Speichern") {
                        if userStore.currentUser == nil {
                            userStore.createUser(
                                fullName: fullName.isEmpty ? "Anonym" : fullName,
                                email: email, nickname: nickname.isEmpty ? "user" : nickname)
                        } else {
                            userStore.updateUser(
                                fullName: fullName.isEmpty ? nil : fullName,
                                email: email.isEmpty ? nil : email,
                                nickname: nickname.isEmpty ? nil : nickname)
                        }
                        dismiss()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.theme.mutedSage)
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
        .background(Color.theme.oatMilk)
}
