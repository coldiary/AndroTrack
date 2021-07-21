//
//  SettingsView.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-14.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var recordStore: RecordStore
    @EnvironmentObject var settingsStore: SettingsStore
    
    @ObservedObject var watchConnectivity = WatchConnectivity.shared
    
    @State private var showNotifPermissionModal = false
    @State private var notificationsAuthorizationStatus: UNAuthorizationStatus?
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 1, day: 1)
        let endComponents = DateComponents(year: 2021, month: 12, day: 1, hour: 23, minute: 59, second: 59)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if watchConnectivity.session.isPaired {
                    if (!watchConnectivity.isReachable) {
                        Text("Watch unreachable, will be synced on opening").foregroundColor(Color.yellow)
                    }
                }
                HStack() {
                    Text("Session length")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Picker("Session Length", selection: $settingsStore.sessionLength) {
                        ForEach(Range(1...24)) { length in
                            Text("\(length - 1)").tag(length)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 80, height: 100)
                    .clipped()
                }
                .padding(.horizontal)
                VStack(alignment: .leading) {
                    Text("Theme color")
                        .font(.title2)
                        .bold()
                    ThemeSelectorView(selected: $settingsStore.themeColor)
                }.padding()
                VStack(alignment: .leading) {
                    Text("Notifications")
                        .font(.title2)
                        .bold()
                    
                    Toggle(isOn: $settingsStore.notifications.notifyEnd) {
                        Text("Notify end of session")
                            .font(.title3)
                            .bold()
                    }.onChange(of: settingsStore.notifications.notifyEnd) { enabled in
                        if enabled {
                            checkCanSendNotifications() {
                                guard let end = recordStore.current.estimatedEnd(forDuration: settingsStore.sessionLength) else {
                                    return
                                }
                                
                                Notifications.scheduleNotifyEndNotification(at: end)
                            }
                        } else {
                            Notifications.cancelNotifyEndNotification()
                        }
                    }
                    
                    Toggle(isOn: $settingsStore.notifications.reminderStart) {
                        Text("Session start reminder")
                            .font(.title3)
                            .bold()
                    }.onChange(of: settingsStore.notifications.reminderStart) { enabled in
                        
                        if enabled {
                            checkCanSendNotifications() {
                                Notifications.scheduleReminderStartNotification()
                            }
                        } else {
                            Notifications.cancelReminderStartNotification()
                        }
                    }
                    
                    if settingsStore.notifications.reminderStart {
                        VStack(alignment: .leading) {
                            Text("Reminder time :")
                                .font(.title3)
                                .bold()
                            DatePicker("", selection: $settingsStore.notifications.reminderTime,
                                       displayedComponents: [.hourAndMinute])
                                .labelsHidden()
                                .datePickerStyle(WheelDatePickerStyle())
                                .frame(height: 100)
                                .clipped()
                                .onChange(of: settingsStore.notifications.reminderTime) { _ in
                                    Notifications.cancelReminderStartNotification()
                                    Notifications.scheduleReminderStartNotification()
                                }
                        }
                    }
                }.padding()
            }
            .sheet(isPresented: $showNotifPermissionModal) {
                GenericModal() {
                    NotificationPermission() {
                        guard let status = notificationsAuthorizationStatus else { return }
                        
                        if status == .notDetermined {
                            Notifications.requestAuthorization { error in
                                if let error = error {
                                    AppLogger.warning(context: "SettingsView", "Failure: \(error.localizedDescription)")
                                }
                            }
                        } else {
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }

                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }
                    }
                }
            }
            .onAppear() {
                checkCanSendNotifications()
            }
            .navigationTitle("Settings")
        }
    }
    
    private func checkCanSendNotifications(completion: @escaping () -> Void = {}) {
        Notifications.checkSettings { settings in
            if let authorizationStatus = settings?.authorizationStatus {
                notificationsAuthorizationStatus = authorizationStatus
                
                if (authorizationStatus == .notDetermined || authorizationStatus == .denied) {
                    showNotifPermissionModal = true
                } else {
                    completion()
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsStore.shared)
            .preferredColorScheme(.dark)
    }
}
