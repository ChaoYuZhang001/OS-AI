//
//  DataModels.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  数据模型 - SwiftData模型定义
//

import Foundation
import SwiftData

// MARK: - Todo Item

@Model
final class TodoItem {
    var id: UUID
    var content: String
    var isCompleted: Bool
    var dueDate: Date?
    var location: String?
    var priority: TodoPriority
    var category: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        content: String,
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        location: String? = nil,
        priority: TodoPriority = .normal,
        category: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.location = location
        self.priority = priority
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum TodoPriority: String, Codable, CaseIterable {
    case low = "低"
    case normal = "正常"
    case high = "高"
    case urgent = "紧急"

    var color: String {
        switch self {
        case .low: return "green"
        case .normal: return "blue"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
}

// MARK: - Calendar Event

@Model
final class CalendarEvent {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var notes: String?
    var attendees: [String]
    var isAllDay: Bool
    var recurrenceRule: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        location: String? = nil,
        notes: String? = nil,
        attendees: [String] = [],
        isAllDay: Bool = false,
        recurrenceRule: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.notes = notes
        self.attendees = attendees
        self.isAllDay = isAllDay
        self.recurrenceRule = recurrenceRule
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Delivery Item

@Model
final class DeliveryItem {
    var id: UUID
    var trackingNumber: String
    var carrier: String
    var status: DeliveryStatus
    var sender: String?
    var receiver: String?
    var estimatedDeliveryDate: Date?
    var actualDeliveryDate: Date?
    var currentLocation: String?
    var trackingHistory: [TrackingUpdate]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        trackingNumber: String,
        carrier: String,
        status: DeliveryStatus = .pending,
        sender: String? = nil,
        receiver: String? = nil,
        estimatedDeliveryDate: Date? = nil,
        actualDeliveryDate: Date? = nil,
        currentLocation: String? = nil,
        trackingHistory: [TrackingUpdate] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.trackingNumber = trackingNumber
        self.carrier = carrier
        self.status = status
        self.sender = sender
        self.receiver = receiver
        self.estimatedDeliveryDate = estimatedDeliveryDate
        self.actualDeliveryDate = actualDeliveryDate
        self.currentLocation = currentLocation
        self.trackingHistory = trackingHistory
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum DeliveryStatus: String, Codable, CaseIterable {
    case pending = "待发货"
    case inTransit = "运输中"
    case outForDelivery = "派送中"
    case delivered = "已送达"
    case failed = "投递失败"
    case returned = "已退回"
}

struct TrackingUpdate: Codable {
    var status: String
    var location: String?
    var timestamp: Date
    var description: String?

    init(status: String, location: String? = nil, timestamp: Date = Date(), description: String? = nil) {
        self.status = status
        self.location = location
        self.timestamp = timestamp
        self.description = description
    }
}

// MARK: - Payment Item

@Model
final class PaymentItem {
    var id: UUID
    var billType: BillType
    var provider: String
    var amount: Double
    var currency: String
    var dueDate: Date
    var isPaid: Bool
    var paidDate: Date?
    var accountNumber: String?
    var autoPayEnabled: Bool
    var reminderEnabled: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        billType: BillType,
        provider: String,
        amount: Double,
        currency: String = "CNY",
        dueDate: Date,
        isPaid: Bool = false,
        paidDate: Date? = nil,
        accountNumber: String? = nil,
        autoPayEnabled: Bool = false,
        reminderEnabled: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.billType = billType
        self.provider = provider
        self.amount = amount
        self.currency = currency
        self.dueDate = dueDate
        self.isPaid = isPaid
        self.paidDate = paidDate
        self.accountNumber = accountNumber
        self.autoPayEnabled = autoPayEnabled
        self.reminderEnabled = reminderEnabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum BillType: String, Codable, CaseIterable {
    case utilities = "水电费"
    case internet = "宽带费"
    case phone = "话费"
    case creditCard = "信用卡"
    case insurance = "保险费"
    case subscription = "订阅费"
    case tax = "税费"
    case other = "其他"

    var icon: String {
        switch self {
        case .utilities: return "⚡️"
        case .internet: return "🌐"
        case .phone: return "📱"
        case .creditCard: return "💳"
        case .insurance: return "🛡️"
        case .subscription: return "📦"
        case .tax: return "🏛️"
        case .other: return "📄"
        }
    }
}

// MARK: - Travel Plan

@Model
final class TravelPlan {
    var id: UUID
    var title: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var transportation: Transportation
    var accommodation: Accommodation
    var itinerary: [ItineraryItem]
    var budget: Double?
    var actualExpense: Double?
    var notes: String?
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        transportation: Transportation,
        accommodation: Accommodation,
        itinerary: [ItineraryItem] = [],
        budget: Double? = nil,
        actualExpense: Double? = nil,
        notes: String? = nil,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.transportation = transportation
        self.accommodation = accommodation
        self.itinerary = itinerary
        self.budget = budget
        self.actualExpense = actualExpense
        self.notes = notes
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct Transportation: Codable {
    var type: TransportType
    var carrier: String
    var flightNumber: String?
    var departureDate: Date
    var arrivalDate: Date
    var departureLocation: String
    var arrivalLocation: String
    var seatNumber: String?
    var bookingReference: String?
    var price: Double?

    init(
        type: TransportType,
        carrier: String,
        flightNumber: String? = nil,
        departureDate: Date,
        arrivalDate: Date,
        departureLocation: String,
        arrivalLocation: String,
        seatNumber: String? = nil,
        bookingReference: String? = nil,
        price: Double? = nil
    ) {
        self.type = type
        self.carrier = carrier
        self.flightNumber = flightNumber
        self.departureDate = departureDate
        self.arrivalDate = arrivalDate
        self.departureLocation = departureLocation
        self.arrivalLocation = arrivalLocation
        self.seatNumber = seatNumber
        self.bookingReference = bookingReference
        self.price = price
    }
}

enum TransportType: String, Codable, CaseIterable {
    case flight = "飞机"
    case train = "火车"
    case bus = "大巴"
    case car = "汽车"
    case ship = "轮船"
}

struct Accommodation: Codable {
    var name: String
    var address: String
    var checkInDate: Date
    var checkOutDate: Date
    var roomType: String
    var numberOfGuests: Int
    var bookingReference: String?
    var price: Double?
    var contact: String?

    init(
        name: String,
        address: String,
        checkInDate: Date,
        checkOutDate: Date,
        roomType: String,
        numberOfGuests: Int,
        bookingReference: String? = nil,
        price: Double? = nil,
        contact: String? = nil
    ) {
        self.name = name
        self.address = address
        self.checkInDate = checkInDate
        self.checkOutDate = checkOutDate
        self.roomType = roomType
        self.numberOfGuests = numberOfGuests
        self.bookingReference = bookingReference
        self.price = price
        self.contact = contact
    }
}

struct ItineraryItem: Codable {
    var id: UUID
    var date: Date
    var time: Date?
    var title: String
    var location: String?
    var description: String?
    var category: ItineraryCategory
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        date: Date,
        time: Date? = nil,
        title: String,
        location: String? = nil,
        description: String? = nil,
        category: ItineraryCategory = .activity,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.date = date
        self.time = time
        self.title = title
        self.location = location
        self.description = description
        self.category = category
        self.isCompleted = isCompleted
    }
}

enum ItineraryCategory: String, Codable, CaseIterable {
    case transportation = "交通"
    case accommodation = "住宿"
    case activity = "活动"
    case dining = "餐饮"
    case shopping = "购物"
    case sightseeing = "观光"
}
