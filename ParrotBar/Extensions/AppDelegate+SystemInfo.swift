//
//  AppDelegate+ SystemInfo.swift
//  ParrotBar
//
//  Created by michael on 7/26/24.
//
//  Assets provided by https://cultofthepartyparrot.com (https://github.com/jmhobbs/cultofthepartyparrot.com)

import Cocoa

// MARK: - System Information

extension AppDelegate {
    @objc internal func updateSystemInfo() {
        // Use background thread
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            // Fetch system info
            let memoryUsage = self.getResidentMemoryUsage()
            let uptime = self.getSystemUptime()
            let diskUsage = self.getDiskUsage()
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.residentMemoryUsageItem.title = "ParrotBar Memory Usage: \(memoryUsage)"
                self.systemUptimeItem.title = "Uptime: \(uptime)"
                self.diskUsageItem.title = "Disk Usage: \(diskUsage)"
            }
        }
    }
    
    // Gets resident memory usage of the app (used and percentage of total)
    private func getResidentMemoryUsage() -> String {
        let MACH_TASK_BASIC_INFO_COUNT = MemoryLayout<mach_task_basic_info>.stride / MemoryLayout<natural_t>.stride
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MACH_TASK_BASIC_INFO_COUNT)

        let kerr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) { infoPtr in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), infoPtr, &count)
            }
        }

        guard kerr == KERN_SUCCESS else {
            return "Memory Info Unknown"
        }

        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let usedMemory = UInt64(info.resident_size)
        let usedMemoryMB = Double(usedMemory) / (1024 * 1024)
        let memoryUsagePercent = Double(usedMemory) / Double(totalMemory) * 100.0

        return String(format: "%.1f MB (%.1f%%)", usedMemoryMB, memoryUsagePercent)
    }

    // Fetches public IP from ipify API and returns it with completion handler
    func getPublicIPAddress(completion: @escaping (String?) -> Void) {
        let urlString = "https://api.ipify.org?format=json"
        
        guard let url = URL(string: urlString) else {
            #if DEBUG
            logger.error("Invalid URL: \(urlString)")
            #endif
            completion(nil)
            return
        }
        #if DEBUG
        logger.debug("Fetching public IP address from \(urlString)")
        #endif
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                #if DEBUG
                self.logger.error("Error fetching IP address: \(error.localizedDescription)")
                #endif
                completion(nil)
                return
            }
            
            guard let data = data else {
                #if DEBUG
                self.logger.error("No data received")
                #endif
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let ipAddress = json["ip"] as? String {
                    completion(ipAddress)
                } else {
                    #if DEBUG
                    self.logger.error("Failed to parse IP addr")
                    #endif
                    completion(nil)
                }
            } catch {
                #if DEBUG
                self.logger.error("Error parsing JSON: \(error.localizedDescription)")
                #endif
                completion(nil)
            }
        }
        
        task.resume()
    }

    // Gets time since last system reboot
    private func getSystemUptime() -> String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .short
        return "\(formatter.string(from: uptime) ?? "Unknown")"
    }
    
    // Gets disk used out of total
    private func getDiskUsage() -> String {
        let fileSystemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        guard let attributes = fileSystemAttributes else { return "Disk Usage: Unknown" }
        
        let freeSpace = attributes[FileAttributeKey.systemFreeSize] as? NSNumber
        let totalSpace = attributes[FileAttributeKey.systemSize] as? NSNumber
        
        let freeSpaceGB = ByteCountFormatter.string(fromByteCount: freeSpace?.int64Value ?? 0, countStyle: .memory)
        let totalSpaceGB = ByteCountFormatter.string(fromByteCount: totalSpace?.int64Value ?? 0, countStyle: .memory)
        
        return "\(freeSpaceGB) free of \(totalSpaceGB)"
    }
}
