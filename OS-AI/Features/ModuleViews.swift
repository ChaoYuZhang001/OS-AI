//
//  TodoModuleView.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  待办事项模块 - 占位视图
//

import SwiftUI

struct TodoModuleView: View {
    let viewModel: TodoViewModel

    var body: some View {
        Text("待办事项模块已就绪")
            .font(.headline)
            .foregroundColor(.green)
    }
}

struct CalendarModuleView: View {
    let viewModel: CalendarViewModel

    var body: some View {
        Text("日程管理模块已就绪")
            .font(.headline)
            .foregroundColor(.green)
    }
}

struct DeliveryModuleView: View {
    let viewModel: DeliveryViewModel

    var body: some View {
        Text("快递查询模块已就绪")
            .font(.headline)
            .foregroundColor(.green)
    }
}

struct PaymentModuleView: View {
    let viewModel: PaymentViewModel

    var body: some View {
        Text("缴费模块已就绪")
            .font(.headline)
            .foregroundColor(.green)
    }
}

struct TravelModuleView: View {
    let viewModel: TravelViewModel

    var body: some View {
        Text("出行规划模块已就绪")
            .font(.headline)
            .foregroundColor(.green)
    }
}

struct ContentProcessingModuleView: View {
    let viewModel: ContentProcessingViewModel

    var body: some View {
        Text("内容处理模块已就绪")
            .font(.headline)
            .foregroundColor(.green)
    }
}
