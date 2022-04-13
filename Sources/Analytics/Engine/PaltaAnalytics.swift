import Amplitude
import PaltaLibCore

public final class PaltaAnalytics {
    public static let instance = PaltaAnalytics()

    var targets = [Target]()
    var amplitudeInstances = [Amplitude]()
    var paltaQueues: [EventQueueImpl] {
        paltaQueueAssemblies.map { $0.eventQueue }
    }

    let assembly = AnalyticsAssembly()
    private(set) var paltaQueueAssemblies: [EventQueueAssembly] = []

    private var apiKey: String?
    private var amplitudeApiKey: String?

    public init() {}

    public func configure(
        name: String,
        amplitudeAPIKey: String? = nil,
        paltaAPIKey: String? = nil,
        trackingSessionEvents: Bool = false
    ) {
        self.apiKey = paltaAPIKey
        self.amplitudeApiKey = amplitudeAPIKey
        requestRemoteConfigs()
    }
    
    private func requestRemoteConfigs() {
        guard let apiKey = apiKey else {
            print("PaltaAnalytics: error: API key is not set")
            return
        }

        assembly.analyticsCoreAssembly.configurationService.requestConfigs(apiKey: apiKey) { [self] result in
            switch result {
            case .failure(let error):
                print("PaltaAnalytics: configuration fetch failed: \(error.localizedDescription), used default config.")
                addConfigTarget(.defaultTarget)
            case .success(let config):
                config.targets.forEach { [self] in
                    addConfigTarget($0)
                }
            }
        }
    }
    
    private func addConfigTarget(_ target: ConfigTarget) {
        switch target.name {
        case .amplitude:
            addAmplitudeTarget(target)
        case .`default`, .paltabrain:
            addPaltaBrainTarget(target)
        }
    }

    private func addAmplitudeTarget(_ target: ConfigTarget) {
        guard let apiKey = amplitudeApiKey else {
            print("PaltaAnalytics: error: API key for amplitude is not set")
            return
        }

        let amplitudeInstance = Amplitude.instance(withName: target.name.rawValue)
        let settings = target.settings
        amplitudeInstance.trackingSessionEvents = settings.trackingSessionEvents
        amplitudeInstance.eventMaxCount = Int32(settings.eventMaxCount)
        amplitudeInstance.eventUploadMaxBatchSize = Int32(settings.eventUploadMaxBatchSize)
        amplitudeInstance.eventUploadPeriodSeconds = Int32(settings.eventUploadPeriodSeconds)
        amplitudeInstance.eventUploadThreshold = Int32(settings.eventUploadThreshold)
        amplitudeInstance.minTimeBetweenSessionsMillis = settings.minTimeBetweenSessionsMillis
        amplitudeInstance.initializeApiKey(apiKey)

        if let url = target.url {
            amplitudeInstance.setServerUrl(url.absoluteString)
        }

        amplitudeInstances.append(amplitudeInstance)
    }

    private func addPaltaBrainTarget(_ target: ConfigTarget) {
        let eventQueueAssembly = assembly.newEventQueueAssembly()

        eventQueueAssembly.eventQueueCore.config = .init(
            maxBatchSize: target.settings.eventUploadMaxBatchSize,
            uploadInterval: TimeInterval(target.settings.eventUploadPeriodSeconds),
            uploadThreshold: target.settings.eventUploadThreshold,
            maxEvents: target.settings.eventMaxCount,
            maxConcurrentOperations: 5
        )

        assembly.analyticsCoreAssembly.sessionManager.maxSessionAge = target.settings.minTimeBetweenSessionsMillis
        paltaQueueAssemblies.append(eventQueueAssembly)
    }

//    public func addTarget(_ target: Target) {
//        guard !targets.contains(target) else { return }
//
//        let amplitudeInstance = Amplitude.instance(withName: target.name)
//        amplitudeInstance.trackingSessionEvents = target.trackingSessionEvents
//        amplitudeInstance.initializeApiKey(target.apiKey)
//
//        if let serverURL = target.serverURL {
//            amplitudeInstance.setServerUrl(serverURL.absoluteString)
//        }
//        amplitudeInstances.append(amplitudeInstance)
//    }
    
//    public func initializeApiKey(apiKey: String) {
//        amplitudeInstances.forEach {
//            $0.initializeApiKey(apiKey)
//        }
//    }
    
//    public func initializeApiKey(apiKey: String, userId: String?) {
//        amplitudeInstances.forEach {
//            $0.initializeApiKey(apiKey, userId: userId)
//        }
//    }
        
    public func setOffline(_ offline: Bool) {
        amplitudeInstances.forEach {
            $0.setOffline(offline)
        }

        paltaQueueAssemblies.forEach {
            $0.eventQueueCore.isPaused = offline
        }
    }
    
    public func useAdvertisingIdForDeviceId() {
        amplitudeInstances.forEach {
            $0.useAdvertisingIdForDeviceId()
        }

        // TODO
    }

    public func setTrackingOptions(_ options: AMPTrackingOptions) {
        amplitudeInstances.forEach {
            $0.setTrackingOptions(options)
        }

        paltaQueueAssemblies.forEach {
            $0.eventComposer.trackingOptions = options
        }
    }

    public func enableCoppaControl() {
        amplitudeInstances.forEach {
            $0.enableCoppaControl()
        }
// TODO
//        paltaQueueAssemblies.forEach {
//            $0.eventComposer.trackingOptions
//        }
    }
    
    public func disableCoppaControl() {
        amplitudeInstances.forEach {
            $0.disableCoppaControl()
        }
        // TODO
    }
    
//    public func setServerUrl(_ serverUrl: String) {
//        amplitudeInstances.forEach {
//            $0.setServerUrl(serverUrl)
//        }
//    }

//    public func setContentTypeHeader(_ contentType: String) {
//        amplitudeInstances.forEach {
//            $0.setContentTypeHeader(contentType)
//        }
//    }
    
//    public func setBearerToken(_ token: String) {
//        amplitudeInstances.forEach {
//            $0.setBearerToken(token)
//        }
//    }
    
//    public func setPlan(_ plan: AMPPlan) {
//        amplitudeInstances.forEach {
//            $0.setPlan(plan)
//        }
//    }

//    public func setServerZone(_ serverZone: AMPServerZone) {
//        amplitudeInstances.forEach {
//            $0.setServerZone(serverZone)
//        }
//    }
    
//    public func setServerZone(_ serverZone: AMPServerZone, updateServerUrl: Bool) {
//        amplitudeInstances.forEach {
//            $0.setServerZone(serverZone,
//                             updateServerUrl: updateServerUrl)
//        }
//    }
    
//    public func printEventsCount() {
//        amplitudeInstances.forEach {
//            $0.printEventsCount()
//        }
//    }
    
    public func getDeviceId() -> String? {
        assembly.analyticsCoreAssembly.userPropertiesKeeper.deviceId
    }
    
    public func regenerateDeviceId() {
        let deviceId = UUID().uuidString.appending("R")
        amplitudeInstances.forEach {
            $0.setDeviceId(deviceId)
        }
        assembly.analyticsCoreAssembly.userPropertiesKeeper.deviceId = deviceId
    }
    
    public func getSessionId() -> Int64? {
        Int64(assembly.analyticsCoreAssembly.sessionManager.sessionId)
    }
    
    public func setSessionId(_ timestamp: Int64) {
        amplitudeInstances.forEach {
            $0.setSessionId(timestamp)
        }

        assembly.analyticsCoreAssembly.sessionManager.setSessionId(Int(timestamp))
    }
    
//    public func uploadEvents() {
//        amplitudeInstances.forEach {
//            $0.uploadEvents()
//        }
//    }

//    public func startOrContinueSession(_ timestamp: Int64) {
//        amplitudeInstances.forEach {
//            $0.startOrContinueSession(timestamp)
//        }
//    }
    
//    public func getContentTypeHeader() -> String? {
//        amplitudeInstances.first?.getContentTypeHeader()
//    }
}
