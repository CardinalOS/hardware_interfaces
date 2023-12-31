/*
 * Copyright (C) 2022 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef MOCK_WIFI_IFACE_UTIL_H_
#define MOCK_WIFI_IFACE_UTIL_H_

#include <gmock/gmock.h>

#include "wifi_iface_util.h"

namespace aidl {
namespace android {
namespace hardware {
namespace wifi {
namespace iface_util {

class MockWifiIfaceUtil : public iface_util::WifiIfaceUtil {
  public:
    MockWifiIfaceUtil(const std::weak_ptr<::android::wifi_system::InterfaceTool> iface_tool,
                      const std::weak_ptr<legacy_hal::WifiLegacyHal> legacy_hal);
    MOCK_METHOD1(getFactoryMacAddress, std::array<uint8_t, 6>(const std::string&));
    MOCK_METHOD2(setMacAddress, bool(const std::string&, const std::array<uint8_t, 6>&));
    MOCK_METHOD0(getOrCreateRandomMacAddress, std::array<uint8_t, 6>());
    MOCK_METHOD2(registerIfaceEventHandlers,
                 void(const std::string&, iface_util::IfaceEventHandlers));
    MOCK_METHOD1(unregisterIfaceEventHandlers, void(const std::string&));
    MOCK_METHOD2(setUpState, bool(const std::string&, bool));
    MOCK_METHOD1(ifNameToIndex, unsigned(const std::string&));
};

}  // namespace iface_util
}  // namespace wifi
}  // namespace hardware
}  // namespace android
}  // namespace aidl

#endif  // MOCK_WIFI_IFACE_UTIL_H_
