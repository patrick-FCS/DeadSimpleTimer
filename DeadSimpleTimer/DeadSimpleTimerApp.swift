//
//  DeadSimpleTimerApp.swift
//  DeadSimpleTimer
//
//  Created by Patrick Burnett-Downie on 2025-05-07.
//

import SwiftUI

@main
struct TinyCountdownApp: App {
    var body: some Scene {
        WindowGroup {
            TinyCountdownView()
        }
    }
}

struct TinyCountdownView: View {
    // MARK: - State
    @State private var totalSeconds: Int = 10          // User‑selected duration
    @State private var secondsRemaining: Int = 10      // Live countdown value
    @State private var isRunning: Bool = false         // Toggle between running & paused
    @State private var timer: Timer? = nil             // Backing timer
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 32) {
            // Title
            Text("Tiny Countdown")
                .font(.largeTitle)
                .bold()

            // Countdown label
            Text(timeString)
                .font(.system(size: 64, weight: .semibold, design: .monospaced))
                .accessibilityLabel("\(secondsRemaining) seconds remaining")

            // Duration picker – simple stepper keeps UX minimal
            Stepper(value: $totalSeconds, in: 1...3600) {
                Text("Duration: \(totalSeconds) s")
            }
            .disabled(isRunning)              // Lock the picker while running
            .onChange(of: totalSeconds) { newValue in
                secondsRemaining = newValue  // Sync live value when user tweaks duration
            }

            // Control buttons
            HStack(spacing: 20) {
                Button(isRunning ? "Pause" : "Start") {
                    isRunning ? pause() : start()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("Reset") {
                    reset()
                }
                .disabled(!isRunning && secondsRemaining == totalSeconds)
            }
        }
        .padding()
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Helpers
    private var timeString: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func start() {
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                timer?.invalidate()
                isRunning = false
                // TODO: optional haptic or sound feedback here
            }
        }
    }

    private func pause() {
        isRunning = false
        timer?.invalidate()
    }

    private func reset() {
        timer?.invalidate()
        isRunning = false
        secondsRemaining = totalSeconds
    }
}

// MARK: - Preview
struct TinyCountdownView_Previews: PreviewProvider {
    static var previews: some View {
        TinyCountdownView()
    }
}
