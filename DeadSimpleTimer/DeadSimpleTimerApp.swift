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
    @AppStorage("selectedAppearance") private var selectedAppearance: String = "system"
    @State private var totalSeconds: Int = 10          // User‑selected duration
    @State private var secondsRemaining: Int = 10      // Live countdown value
    @State private var isRunning: Bool = false         // Countdown running?
    @State private var timer: Timer?                   // Backing timer
    @State private var showDurationPicker: Bool = false   // Controls the sheet
    @State private var inputDuration: String = ""         // Temp text‑field binding
    @State private var showDurationWarning: Bool = false

    private var resolvedColorScheme: ColorScheme? {
        switch selectedAppearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    // MARK: - UI
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Big monospace clock
                Text(format(seconds: secondsRemaining))
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .padding(.vertical, 16)
                    .onTapGesture {
                        if !isRunning {
                            inputDuration = String(totalSeconds)
                            showDurationPicker = true
                        }
                    }

                // Controls
                HStack(spacing: 12) {
                    Button(isRunning ? "Pause" : "Start") { toggleRunning() }
                        .buttonStyle(.borderedProminent)

                    Button("Reset") { reset() }
                        .disabled(!isRunning && secondsRemaining == totalSeconds)

                    Stepper("", value: Binding(
                        get: { secondsRemaining },
                        set: { newValue in
                            secondsRemaining = newValue
                            totalSeconds = newValue
                        }
                    ), in: 1...36000, step: 1)
                    .disabled(isRunning)
                }
                .padding(.horizontal, 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .onChange(of: isRunning) { oldValue, newValue in
                newValue ? start() : pause()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Light") { selectedAppearance = "light" }
                        Button("Dark") { selectedAppearance = "dark" }
                        Button("System") { selectedAppearance = "system" }
                    } label: {
                        Image(systemName: "lightbulb")
                    }
                }
            }
        }
      .environment(\.colorScheme, resolvedColorScheme ?? .light)
        .sheet(isPresented: $showDurationPicker) {
            NavigationView {
                Form {
                    TextField("Seconds (1–36000)", text: $inputDuration)
                        .keyboardType(.numberPad)
                        .onChange(of: inputDuration) { _, newValue in
                            let cleaned = cleanDurationInput(newValue)
                            if cleaned != newValue {
                                showDurationWarning = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    showDurationWarning = false
                                }
                            }
                            inputDuration = cleaned
                        }
                    if showDurationWarning {
                        Text("Duration must be between 1 and 36000 seconds")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .navigationBarTitle("Set Duration", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            if let value = Int(inputDuration),
                               (1...36000).contains(value) {
                                totalSeconds = value
                                secondsRemaining = value
                            }
                            showDurationPicker = false
                        }
                        .disabled(!(Int(inputDuration).map { (1...36000).contains($0) } ?? false))
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
                notifyCompletion()
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
    
    private func notifyCompletion() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func cleanDurationInput(_ raw: String) -> String {
        let filtered = raw.filter { "0123456789".contains($0) }
        if let intVal = Int(filtered) {
            return String(min(max(intVal, 1), 36000))
        }
        return "1"
    }
}

struct TinyCountdownView_Previews: PreviewProvider {
    static var previews: some View {
        TinyCountdownView()
            .previewLayout(.sizeThatFits)
    }
}
