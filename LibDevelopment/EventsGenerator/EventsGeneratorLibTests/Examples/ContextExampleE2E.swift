//  

import Foundation
import PaltaAnlyticsTransport

public struct Context: BatchContext {
    public var application: Application

    public var appsflyer: Appsflyer

    public var device: Device

    public var identify: Identify

    public var os: Os

    public var user: User

    internal var message: Context {
        get {
            PaltaAnlyticsTransport.Context.with {
                $0.application = application.message
                $0.appsflyer = appsflyer.message
                $0.device = device.message
                $0.identify = identify.message
                $0.os = os.message
                $0.user = user.message
            }
        }
    } 

    public init() {
        application = Application()
        appsflyer = Appsflyer()
        device = Device()
        identify = Identify()
        os = Os()
        user = User()
    }

    public init(data: Data) {
        let proto = try PaltaAnlyticsTransport.Context(serializedData: data)
        application = Application(message: proto.contextApplication
        appsflyer = Appsflyer(message: proto.contextAppsflyer
        device = Device(message: proto.contextDevice
        identify = Identify(message: proto.contextIdentify
        os = Os(message: proto.contextOs
        user = User(message: proto.contextUser
    }

    public func serialize() throws -> Data {
        try message.serializedData()
    }
}

extension Context {
    public struct Application {
        internal var message: ContextApplication

        public init(appId: String, appPlatform: String, appVersion: String) {
            message = .init()
            message.appId = appId
            message.appPlatform = appPlatform
            message.appVersion = appVersion
        }
    }

    public struct Appsflyer {
        internal var message: ContextAppsflyer

        public init(appsflyerId: String, appsflyerMediaSource: String) {
            message = .init()
            message.appsflyerId = appsflyerId
            message.appsflyerMediaSource = appsflyerMediaSource
        }
    }

    public struct Device {
        internal var message: ContextDevice

        public init(deviceBrand: String, deviceCarrier: String, deviceModel: String) {
            message = .init()
            message.deviceBrand = deviceBrand
            message.deviceCarrier = deviceCarrier
            message.deviceModel = deviceModel
        }
    }

    public struct Identify {
        internal var message: ContextIdentify

        public init(gaid: String, idfa: String, idfv: String) {
            message = .init()
            message.gaid = gaid
            message.idfa = idfa
            message.idfv = idfv
        }
    }

    public struct Os {
        internal var message: ContextOs

        public init(osName: String, osVersion: String) {
            message = .init()
            message.osName = osName
            message.osVersion = osVersion
        }
    }

    public struct User {
        internal var message: ContextUser

        public init(userId: String) {
            message = .init()
            message.userId = userId
        }
    }
}