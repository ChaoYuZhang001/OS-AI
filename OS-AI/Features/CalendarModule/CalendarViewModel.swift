//
//  CalendarViewModel.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  日程管理模块 - ViewModel
//

import Foundation
import SwiftData
import EventKit
import Observation

@Observable
final class CalendarViewModel {

    // MARK: - Properties
    private let modelContext: ModelContext
    private let eventStore = EKEventStore()
    private var items: [CalendarEvent] = []

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadItems()
    }

    // MARK: - Public Methods

    /// 加载日程
    func loadItems() {
        let fetchDescriptor = FetchDescriptor<CalendarEvent>(
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )

        do {
            items = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("❌ Failed to load calendar events: \(error)")
        }
    }

    /// 创建日程
    func createEvent(
        title: String,
        startDate: Date,
        endDate: Date,
        location: String? = nil,
        notes: String? = nil,
        attendees: [String] = [],
        isAllDay: Bool = false
    ) -> CalendarEvent? {
        let event = CalendarEvent(
            title: title,
            startDate: startDate,
            endDate: endDate,
            location: location,
            notes: notes,
            attendees: attendees,
            isAllDay: isAllDay
        )

        modelContext.insert(event)

        do {
            try modelContext.save()
            items.append(event)

            // 同步到系统日历
            syncToSystemCalendar(event)

            print("✅ Calendar event created: \(title)")
            return event
        } catch {
            print("❌ Failed to create calendar event: \(error)")
            return nil
        }
    }

    /// 更新日程
    func updateEvent(
        _ event: CalendarEvent,
        title: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        location: String? = nil,
        notes: String? = nil
    ) {
        if let title = title { event.title = title }
        if let startDate = startDate { event.startDate = startDate }
        if let endDate = endDate { event.endDate = endDate }
        if let location = location { event.location = location }
        if let notes = notes { event.notes = notes }

        event.updatedAt = Date()

        do {
            try modelContext.save()
            print("✅ Calendar event updated: \(event.title)")
        } catch {
            print("❌ Failed to update calendar event: \(error)")
        }
    }

    /// 删除日程
    func deleteEvent(_ event: CalendarEvent) {
        modelContext.delete(event)

        do {
            try modelContext.save()
            items.removeAll { $0.id == event.id }
            print("✅ Calendar event deleted: \(event.title)")
        } catch {
            print("❌ Failed to delete calendar event: \(error)")
        }
    }

    /// 获取指定日期的日程
    func getEvents(for date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return items.filter { event in
            return event.startDate >= startOfDay && event.startDate < endOfDay
        }
    }

    /// 获取指定日期范围的日程
    func getEvents(from startDate: Date, to endDate: Date) -> [CalendarEvent] {
        return items.filter { event in
            return event.startDate >= startDate && event.startDate < endDate
        }
    }

    /// 获取今日日程
    func getTodayEvents() -> [CalendarEvent] {
        return getEvents(for: Date())
    }

    /// 获取即将到来的日程（7天内）
    func getUpcomingEvents() -> [CalendarEvent] {
        let now = Date()
        let sevenDaysLater = Calendar.current.date(byAdding: .day, value: 7, to: now)!

        return items
            .filter { $0.startDate >= now && $0.startDate < sevenDaysLater }
            .sorted { $0.startDate < $1.startDate }
    }

    /// 搜索日程
    func searchEvents(_ query: String) -> [CalendarEvent] {
        let lowercaseQuery = query.lowercased()
        return items.filter { event in
            return event.title.lowercased().contains(lowercaseQuery) ||
                   (event.location?.lowercased().contains(lowercaseQuery) ?? false) ||
                   (event.notes?.lowercased().contains(lowercaseQuery) ?? false)
        }
    }

    // MARK: - System Calendar Integration

    private func syncToSystemCalendar(_ event: CalendarEvent) {
        let systemEvent = EKEvent(eventStore: eventStore)
        systemEvent.title = event.title
        systemEvent.startDate = event.startDate
        systemEvent.endDate = event.endDate
        systemEvent.location = event.location
        systemEvent.notes = event.notes
        systemEvent.isAllDay = event.isAllDay
        systemEvent.calendar = eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(systemEvent, span: .thisEvent)
            print("✅ Event synced to system calendar")
        } catch {
            print("❌ Failed to sync to system calendar: \(error)")
        }
    }
}
