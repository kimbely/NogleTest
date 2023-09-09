//
//  SocketManager.swift
//  NogleTest
//
//  Created by 金梅劉 on 2023/9/9.
//

import Foundation
import Starscream
import RxSwift


class SocketManager: WebSocketDelegate {
    
    static let shared = SocketManager()
    
    private var socket: WebSocket!
    private let socketURL = URL(string: "wss://ws.btse.com/ws/futures")!
    var dataSubject: BehaviorSubject<FuturesData> = BehaviorSubject<FuturesData>(value: FuturesData(topic: "", data: [:]))

    private init() {
        var request = URLRequest(url: socketURL)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    // MARK: - WebSocketDelegate methods
    
    func websocketDidConnect(socket: WebSocketClient) {
        let subscribeMessage = "{\"op\": \"subscribe\", \"args\": [\"coinIndex\"]}"
        socket.write(string: subscribeMessage)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let data = text.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                let futuresData = try decoder.decode(FuturesData.self, from: data)
                dataSubject.onNext(futuresData)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}
