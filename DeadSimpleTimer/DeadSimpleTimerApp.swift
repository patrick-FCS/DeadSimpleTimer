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
    @State private var isRunning: Bool = false         // Countdown running?
    @State private var timer: Timer?                   // Backing timer
    @State private var showDurationPicker: Bool = false   // Controls the sheet
    @State private var inputDuration: String = ""         // Temp text‑field binding

    // MARK: - UI
    var body: some View {
        VStack(spacing: 32) {
            // Big monospace clock
            Text(format(seconds: secondsRemaining))
                .font(.system(size: 64, weight: .bold, design: .monospaced))
                .padding(.vertical, 16)
                .onTapGesture {
                    inputDuration = String(totalSeconds)
                    showDurationPicker = true
                }

            // Duration stepper (disabled while running)
            Stepper(value: $totalSeconds, in: 1...3600, step: 1) {
                Text("Duration: \(format(seconds: totalSeconds))")
            }
            .disabled(isRunning)
            .padding(.horizontal)

            // Controls
            HStack(spacing: 20) {
                Button(isRunning ? "Pause" : "Start") { toggleRunning() }
                    .buttonStyle(.borderedProminent)

                Button("Reset") { reset() }
                    .disabled(!isRunning && secondsRemaining == totalSeconds)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onAppear { reset() }
        .onChange(of: isRunning) { oldValue, newValue in
            newValue ? start() : pause()
        }
        .onChange(of: totalSeconds) { _, newValue in
            secondsRemaining = newValue
        }
        .sheet(isPresented: $showDurationPicker) {
            NavigationView {
                Form {
                    TextField("Seconds (1–3600)", text: $inputDuration)
                        .keyboardType(.numberPad)
                }
                .navigationBarTitle("Set Duration", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            if let value = Int(inputDuration),
                               (1...3600).contains(value) {
                                totalSeconds = value
                                secondsRemaining = value
                            }
                            showDurationPicker = false
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showDurationPicker = false }
                    }
                }
            }
        }
    }

    // MARK: - Timer helpers
    private func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                pause()
                // TODO: Add haptic / sound if desired
            }
        }
    }

    private func pause() {
        timer?.invalidate()
        timer = nil
    }

    private func reset() {
        pause()
        secondsRemaining = totalSeconds
        isRunning = false
    }

    private func toggleRunning() { isRunning.toggle() }

    // MARK: - Utils
    private func format(seconds: Int) -> String {
        let h = seconds / 36000
        let m = (seconds % 36000) / 60
        let s = seconds % 60
        return h > 0 ? String(format: "%02d:%02d:%02d", h, m, s)
                     : String(format: "%02d:%02d", m, s)
    }
}

struct TinyCountdownView_Previews: PreviewProvider {
    static var previews: some View {
        TinyCountdownView()
            .previewLayout(.sizeThatFits)
    }
}
