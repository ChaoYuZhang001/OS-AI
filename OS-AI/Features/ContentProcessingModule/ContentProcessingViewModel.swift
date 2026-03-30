//
//  ContentProcessingViewModel.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  内容处理模块 - ViewModel
//

import Foundation
import Vision
import NaturalLanguage
import Observation

@Observable
final class ContentProcessingViewModel {

    // MARK: - Properties
    private let textRecognizer = VNRecognizeTextRequest()
    @Published var isProcessing = false
    @Published var processingResult: String = ""
    @Published var extractedText: String = ""

    // MARK: - Initialization
    init() {
        setupTextRecognizer()
    }

    // MARK: - Public Methods

    /// 从图片中提取文字
    func extractTextFromImage(imageURL: URL) async -> String? {
        isProcessing = true
        defer { isProcessing = false }

        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            processingResult = "无法加载图片"
            return nil
        }

        guard let cgImage = image.cgImage else {
            processingResult = "图片格式不支持"
            return nil
        }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    self.processingResult = "文字识别失败: \(error.localizedDescription)"
                    continuation.resume(returning: nil)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    self.processingResult = "未检测到文字"
                    continuation.resume(returning: nil)
                    return
                }

                let text = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")

                self.extractedText = text
                self.processingResult = "成功提取 \(observations.count) 行文字"
                continuation.resume(returning: text)
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US", "ja"]

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                self.processingResult = "处理失败: \(error.localizedDescription)"
                continuation.resume(returning: nil)
            }
        }
    }

    /// 生成文本摘要
    func generateSummary(for text: String) async -> String {
        isProcessing = true
        defer { isProcessing = false }

        // 使用NaturalLanguage进行简单摘要
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".。!！?？\n"))
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        // 返回前3句作为摘要
        let summary = sentences.prefix(3).joined(separator: "。") + "。"
        processingResult = "摘要生成完成"

        return summary
    }

    /// 提取关键信息
    func extractKeyInformation(from text: String) -> [KeyInfo] {
        var keyInfos: [KeyInfo] = []

        // 提取日期
        let dateDetector = NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let dateMatches = dateDetector.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))

        for match in dateMatches {
            if let date = match.date {
                keyInfos.append(KeyInfo(type: .date, value: formatDate(date)))
            }
        }

        // 提取电话号码
        let phoneDetector = NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        let phoneMatches = phoneDetector.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))

        for match in phoneMatches {
            if let phone = match.phoneNumber {
                keyInfos.append(KeyInfo(type: .phone, value: phone))
            }
        }

        // 提取URL
        let urlDetector = NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let urlMatches = urlDetector.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))

        for match in urlMatches {
            if let url = match.url {
                keyInfos.append(KeyInfo(type: .url, value: url.absoluteString))
            }
        }

        return keyInfos
    }

    /// 分析文本情感
    func analyzeSentiment(for text: String) -> SentimentScore {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text

        var sentimentScores: [Double] = []

        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .paragraph, scheme: .sentimentScore) { tag, _ in
            if let score = tag?.rawValue.flatMap(Double.init) {
                sentimentScores.append(score)
            }
            return true
        }

        let averageScore = sentimentScores.isEmpty ? 0.0 : sentimentScores.reduce(0, +) / Double(sentimentScores.count)

        let sentiment: Sentiment
        if averageScore > 0.3 {
            sentiment = .positive
        } else if averageScore < -0.3 {
            sentiment = .negative
        } else {
            sentiment = .neutral
        }

        return SentimentScore(
            sentiment: sentiment,
            score: averageScore
        )
    }

    /// 翻译文本
    func translateText(_ text: String, to language: String = "en") async -> String {
        isProcessing = true
        defer { isProcessing = false }

        // 这里可以调用Apple的翻译API或第三方服务
        // 目前返回原文
        processingResult = "翻译功能待实现"
        return text
    }

    // MARK: - Private Methods

    private func setupTextRecognizer() {
        textRecognizer.recognitionLevel = .accurate
        textRecognizer.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US", "ja"]
        textRecognizer.usesLanguageCorrection = true
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Types

struct KeyInfo {
    let type: KeyInfoType
    let value: String
}

enum KeyInfoType {
    case date
    case phone
    case url
    case email
    case address
}

struct SentimentScore {
    let sentiment: Sentiment
    let score: Double
}

enum Sentiment {
    case positive
    case neutral
    case negative

    var description: String {
        switch self {
        case .positive: return "积极"
        case .neutral: return "中性"
        case .negative: return "消极"
        }
    }
}
