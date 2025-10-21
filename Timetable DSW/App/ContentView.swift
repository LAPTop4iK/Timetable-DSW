//
//  ContentView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct ContentView: View {
    // MARK: - Configuration
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let springResponse: Double = 0.4
            let springDamping: Double = 0.8
        }
        static let constants = Constants()
    }

    // MARK: - Properties
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTab = 0

    // MARK: - Dependencies
    private let tabs: [TabBarItem] = [
        TabBarItem(icon: .calendar,    title: .tabsSchedule, tag: 0),
        TabBarItem(icon: .listBullet,  title: .tabsSubjects, tag: 1),
        TabBarItem(icon: .people,      title: .tabsTeachers, tag: 2),
        TabBarItem(icon: .gear,        title: .tabsSettings, tag: 3)
    ]

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
            FloatingTabBar(tabs: tabs, selectedTab: $selectedTab)
        }
        .task {
            await appViewModel.loadGroupsIfNeeded()
        }
    }

    // MARK: - Subviews
    private var contentView: some View {
        Group {
            switch selectedTab {
            case 0:
                ScheduleView()
                    .transition(tabTransition)
            case 1:
                SubjectsView()
                    .transition(tabTransition)
            case 2:
                TeachersView(viewModel: TeachersViewModel())
                    .transition(tabTransition)
            case 3:
                SettingsView()
                    .transition(tabTransition)
            default:
                EmptyView()
            }
        }
        .animation(
            .spring(response: Configuration.constants.springResponse,
                    dampingFraction: Configuration.constants.springDamping),
            value: selectedTab
        )
    }

    // MARK: - Computed Properties
    private var tabTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
