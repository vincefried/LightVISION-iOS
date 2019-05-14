//
//  BluetoothWorker.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 19.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import CoreBluetooth

enum ConnectionState {
    case connecting, connected, disconnected
}

protocol BluetoothWorkerDelegate {
    func changedConnectionState(_ state: ConnectionState)
    func connectedDevice(_ device: BluetoothDevice)
    func disconnectedDevice(_ device: BluetoothDevice)
}

class BluetoothWorker: NSObject {
    
    let manager = CBCentralManager()

    var delegate: BluetoothWorkerDelegate?
    var peripherals = [CBPeripheral]()
    var service: CBService?
    var characteristic: CBCharacteristic?
    
    
    var connectionState: ConnectionState = .disconnected {
        didSet {
            delegate?.changedConnectionState(connectionState)
        }
    }
    
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
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func scanAndConnect(with device: BluetoothDevice = .laservision, delay: TimeInterval = 0.5) {
        scan()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in self?.connect() }
    }
    
    func scan() {
        connectionState = .connecting
        let options = [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(value: false)]
        manager.scanForPeripherals(withServices: nil, options: options)
    }
    
    func connect(with device: BluetoothDevice = .laservision) {
        guard let peripheral = peripherals.first(where: { $0.name == device.name }) else {
            print("No device found with given name: \(device.name)")
            return
        }
        
        if connectedPeripheral != peripheral {
            manager.connect(peripheral)
        }
    }
    
    func disconnect(with device: BluetoothDevice = .laservision) {
        guard let peripheral = connectedPeripheral,
            peripheral.name == device.name else {
            print("No device connected with given name: \(device.name)")
            return
        }
        
        if connectedPeripheral == peripheral {
            manager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func send(_ command: BluetoothCommand) {
        guard let data = command.jsonData, let characteristic = characteristic else { return }
        connectedPeripheral?.writeValue(data, for: characteristic, type: .withoutResponse)
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
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("did fail to connect to \(peripheral.name ?? "Unbekannt")")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("did disconnect to \(peripheral.name ?? "Unbekannt")")
        connectedPeripheral = nil
        service = nil
        characteristic = nil
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

