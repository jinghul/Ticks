//
//  BackgroundAudioManager.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/28/25.
//

import AVFoundation

class BackgroundAudioManager {
    static let shared = BackgroundAudioManager()

    private var audioPlayer: AVAudioPlayer?

    private init() {
        setupAudioSession()
        setupSilentAudio()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    private func setupSilentAudio() {
        // Create a 1-second silent audio buffer
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let frameCount = AVAudioFrameCount(44100)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        // Write silent audio to temp file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("silence.wav")

        do {
            let audioFile = try AVAudioFile(forWriting: tempURL, settings: format.settings)
            try audioFile.write(from: buffer)

            audioPlayer = try AVAudioPlayer(contentsOf: tempURL)
            audioPlayer?.numberOfLoops = -1 // Infinite loop
            audioPlayer?.volume = 0.001 // Nearly silent
        } catch {
            print("Failed to setup silent audio: \(error)")
        }
    }

    func startBackgroundAudio() {
        audioPlayer?.play()
    }

    func stopBackgroundAudio() {
        audioPlayer?.pause()
    }
}
