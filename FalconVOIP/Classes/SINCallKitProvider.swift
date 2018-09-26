//
//  SINCallKitProvider.swift
//  Q8ForSale
//
//  Created by Basim Alamuddin on 7/12/18.
//  Copyright © 2018 Nahla Mortada. All rights reserved.
//

import CallKit
import Sinch

@available(iOS 10.0, *)
public class SINCallKitProvider : NSObject {
    
    fileprivate var client: SINClient
    private var provider: CXProvider
    fileprivate var calls: [UUID: SINCall]
    private var muted: Bool
    
    public static var instance: SINCallKitProvider!
    
    public static func make(with client: SINClient) {
        instance = SINCallKitProvider(with: client)
    }
    
    private init(with client: SINClient) {
        
        self.client = client
        calls = [UUID: SINCall]()
        muted = false
        
        let config = CXProviderConfiguration(localizedName: "4sale") // the text appears on the CallKit screen
        config.maximumCallGroups = 1
        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.phoneNumber, .generic]
        config.supportsVideo = true
        if #available(iOS 11.0, *) {
            config.includesCallsInRecents = true
        }
        provider = CXProvider(configuration: config)
        
        super.init()
        
        provider.setDelegate(self, queue: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.callDidEstablish(_:)), name: NSNotification.Name.SINCallDidEstablish, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.callDidEnd), name: NSNotification.Name.SINCallDidEnd, object: nil)
    }
    
    public func reportNewIncomingCall(call: SINCall) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: call.remoteUserId)
        
        provider.reportNewIncomingCall(with: UUID(uuidString: call.callId)!, update: update, completion: {(_ error: Error?) -> Void in
            if error == nil {
                self.addNewCall(call)
            }
        })
    }
    
    public func callExists(callId: String) -> Bool {
        if calls.count == 0 {
            return false
        }
        
        for callKitCall in calls.values {
            if (callKitCall.callId == callId) {
                return true
            }
        }
        
        return false
    }
    
    public func currentEstablishedCall() -> SINCall? {
        
        let calls = activeCalls()
        
        if calls.count == 1 && calls[0].state == .established {
            return calls[0]
        } else {
            return nil
        }
    }
    
    private func addNewCall(_ call: SINCall) {
        calls[UUID(uuidString: call.callId)!] = call
    }
    
    @objc private func callDidEstablish(_ notification: Notification) {
//        let call = notification.userInfo?[SINCallKey] as? SINCall
//        if let call = call {
//
//        }
    }
    
    // Handle cancel/bye event initiated by either caller or callee
    @objc private func callDidEnd(_ notification: Notification) {
        
        let call = notification.userInfo?[SINCallKey] as? SINCall
        if let call = call {
            let callUDID = UUID(uuidString: call.callId)!
            
            provider.reportCall(with: callUDID, endedAt: call.details.endedTime, reason: getCallEndedReason(cause: call.details.endCause))
            
            if callExists(callId: call.callId) {
                calls.removeValue(forKey: callUDID)
            }
        } else {
            print("Sinch WARNING: No Call was reported as ended on SINCallDidEndNotification")
        }
    }
    
    private func activeCalls() -> [SINCall] {
        return []
    }
    
    private func getCallEndedReason(cause: SINCallEndCause) -> CXCallEndedReason {
        switch cause {
        case .error:
            return .failed
        case .denied:
            return .remoteEnded
        case .hungUp:
            // This mapping is not really correct, as .hungUp is the end case also when the local peer ended the call.
            return .remoteEnded
        case .timeout:
            return .unanswered
        case .canceled:
            return .unanswered
        case .noAnswer:
            return .unanswered
        case .otherDeviceAnswered:
            return .unanswered
        default:
            return .failed
        }
    }
    
}

@available(iOS 10.0, *)
extension SINCallKitProvider : CXProviderDelegate {
    
    public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        client.call().provider(provider, didActivate: audioSession)
    }
    
    private func call(for action: CXCallAction) -> SINCall? {
        let call = calls[action.callUUID]
        if call == nil {
            print("Sinch WARNING: No call found for (\(action.callUUID))")
        }
        return call
    }
    
    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        call(for: action)?.answer()
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        call(for: action)?.hangup()
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        print("Sinch  [CXProviderDelegate performSetMutedCallAction:]")
        
        
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("Sinch -[CXProviderDelegate didDeactivateAudioSession:]");
    }
    
    public func providerDidReset(_ provider: CXProvider) {
        print("Sinch -[CXProviderDelegate providerDidReset:]");
    }
    
}
