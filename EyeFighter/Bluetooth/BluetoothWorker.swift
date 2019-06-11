//
//  BluetoothWorker.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 19.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import CoreBluetooth


/// An enum, representing the current bluetooth connection state.
///
/// - connecting: The worker is currently scanning for devices and waiting for the target device to appear.
/// - connected: The worker is currently connected to the target device.
/// - disconnected: The worker is currently not connected to any device.
/// - deviceNotFound: The worker was not able to find the target device.
enum ConnectionState {
    case connecting, connected, disconnected, deviceNotFound
}

protocol BluetoothWorkerDelegate {
    /// Gets called if the bluetooth connection state did changed.
    ///
    /// - Parameter state: The new state.
    func changedConnectionState(_ state: ConnectionState)
    /// Gets called a bluetooth device connected successfully.
    ///
    /// - Parameter device: The device that connected successfully.
    func connectedDevice(_ device: BluetoothDevice)
    /// Gets called a bluetooth device disconnected successfully.
    ///
    /// - Parameter device: The device that disconnected successfully.
    func disconnectedDevice(_ device: BluetoothDevice)
}


/// A worker class that handles the bluetooth connection using Apple's `CoreBluetooth` framework and wraps it in simple calls.
/// - Tag: BluetoothWorker
class BluetoothWorker: NSObject {
    
    // MARK: - Variables
    
    /// The maximum package size that the worker is able to send to the connected bluetooth device.
    /// # BLE Specs:
    /// - 4.0: **20 Bytes** actual package size for data
    /// - 4.2 and 5.0: **242 Bytes** actual package size for data
    ///
    /// Follow this [link to StackOverflow](https://stackoverflow.com/questions/38913743/maximum-packet-length-for-bluetooth-le) for more.
    /// - Tag: maximumPackageSize
    var maximumPackageSize: Int?
    
    /// The iOS bluetooth manager.
    let manager = CBCentralManager()
    
    /// The bluetooth worker delegate
    var delegate: BluetoothWorkerDelegate?
    /// A list of connected bluetooth peripherals
    var peripherals = [CBPeripheral]()
    /// The service, recognized by the currently connected bluetooth device.
    var service: CBService?
    /// The characteristic, recognized by the currently connected bluetooth device.
    var characteristic: CBCharacteristic?
    
    /// The current connection state.
    var connectionState: ConnectionState = .disconnected {
        didSet {
            delegate?.changedConnectionState(connectionState)
        }
    }
    
    /// Indicates if the device is connected.
    var isConnected: Bool {
        return connectionState == .connected
    }
    
    /// An instance of the currently connected `CBPeripheral`.
    private var _connectedPeripheral: CBPeripheral?
    var connectedPeripheral: CBPeripheral? {
        set {
            if let peripheral = newValue {
                guard service != nil
                    && characteristic != nil,
                    let deviceName = peripheral.name,
                    let device = BluetoothDevice(rawValue: deviceName) else { return }
                connectionState = .connected
                delegate?.connectedDevice(device)
            } else {
                guard let oldPeripheral = _connectedPeripheral,
                let deviceName = oldPeripheral.name,
                let device = BluetoothDevice(rawValue: deviceName) else { return }
                connectionState = .disconnected
                delegate?.disconnectedDevice(device)
            }
            
            _connectedPeripheral = newValue
        }
        
        get {
            return _connectedPeripheral
        }
    }
    
    // MARK: - Functions
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    /// Scans for [BluetoothDevice](x-source-tag://BluetoothDevice)s nearby and autoconnects after a given delay.
    ///
    /// - Parameters:
    ///   - device: The [BluetoothDevice](x-source-tag://BluetoothDevice) to scan for.
    ///   - delay: The delay to wait for between starting to scan and trying to connect.
    func scanAndConnect(with device: BluetoothDevice = .lightvision, delay: TimeInterval = 1.0) {
        scan()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in self?.connect(with: device) }
    }
    
    /// Starts the bluetooth scan.
    func scan() {
        connectionState = .connecting
        let options = [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(value: false)]
        manager.scanForPeripherals(withServices: nil, options: options)
    }
    
    /// Connects with a given [BluetoothDevice](x-source-tag://BluetoothDevice).
    ///
    /// - Parameter device: The [BluetoothDevice](x-source-tag://BluetoothDevice) to connect with.
    func connect(with device: BluetoothDevice = .lightvision) {
        guard let peripheral = peripherals.first(where: { $0.name == device.name }) else {
            print("No device found with given name: \(device.name)")
            connectionState = .deviceNotFound
            return
        }
        
        if connectedPeripheral != peripheral {
            manager.connect(peripheral)
        }
    }
    
    /// Cancels the bluetooth connection to a given [BluetoothDevice](x-source-tag://BluetoothDevice).
    ///
    /// - Parameter device: The [BluetoothDevice](x-source-tag://BluetoothDevice) to cancel the bluetooth connection with.
    func disconnect(with device: BluetoothDevice = .lightvision) {
        guard let peripheral = connectedPeripheral,
            peripheral.name == device.name else {
            print("No device connected with given name: \(device.name)")
            return
        }
        
        if connectedPeripheral == peripheral {
            manager.cancelPeripheralConnection(peripheral)
        }
    }
    
    /// Sends a [BluetoothCommand](x-source-tag://BluetoothCommand) to a connected [BluetoothDevice](x-source-tag://BluetoothDevice).
    /// Does nothing if the [BluetoothDevice](x-source-tag://BluetoothDevice) is not fully connected and configured
    /// or the command as data exceeds the maximum allowed package size by the used BLE standard.
    ///
    /// - Parameter command: The [BluetoothCommand](x-source-tag://BluetoothCommand) to send.
    ///
    /// - Note: See [maximumPackageSize](x-source-tag://maximumPackageSize) for BLE Specs.
    func send(_ command: BluetoothCommand) {
        guard let data = command.data else { return }
        send(data: data)
    }
    
    /// Sends `Data` to a connected [BluetoothDevice](x-source-tag://BluetoothDevice).
    /// Does nothing if the [BluetoothDevice](x-source-tag://BluetoothDevice) is not fully connected and configured
    /// or the command as data exceeds the maximum allowed package size by the used BLE standard.
    ///
    /// - Parameter data: The data to send via bluetooth.
    ///
    /// - Note: See [maximumPackageSize](x-source-tag://maximumPackageSize) for BLE Specs.
    func send(data: Data) {
        guard let characteristic = characteristic, let maximumPackageSize = maximumPackageSize else { return }
        if data.count > maximumPackageSize {
            print("Connected Peripheral does not support package size \(data.count). Maximum is \(maximumPackageSize)")
        } else {
            connectedPeripheral?.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
}

extension BluetoothWorker: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("poweredOn")
        case .poweredOff:
            print("poweredOff")
        case .resetting:
            print("resetting")
        case .unauthorized:
            print("unauthorized")
        case .unknown:
            print("unkown")
        case .unsupported:
            print("unsupported")
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("did connect to \(peripheral.name ?? "Unbekannt")")
        central.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        maximumPackageSize = peripheral.maximumWriteValueLength(for: .withoutResponse)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("did fail to connect to \(peripheral.name ?? "Unbekannt")")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("did disconnect to \(peripheral.name ?? "Unbekannt")")
        connectedPeripheral = nil
        service = nil
        characteristic = nil
        maximumPackageSize = nil
    }
}

extension BluetoothWorker: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = peripheral.services?.first else { return }
        print("did discover service \(service)")
        self.service = service
        peripheral.discoverCharacteristics(nil, for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristic = service.characteristics?.first else { return }
        print("did discover characteristic \(characteristic)")
        self.characteristic = characteristic
        
        peripheral.setNotifyValue(true, for: characteristic)
        
        connectedPeripheral = peripheral
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("write failed \(error)")
            return
        }
        
        print("write succeeded")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("\(characteristic) is notifying")
        self.characteristic = characteristic
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("\(characteristic) did update")
        self.characteristic = characteristic
    }
}

