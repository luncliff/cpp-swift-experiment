#include <Foundation/Foundation.hpp>

#include "swift_hostinfo.hpp"

namespace experiment {

HostInfo *HostInfo::alloc() noexcept {
  objc_class *cls = objc_lookUpClass("BaguetteBridge.HostInfo");
  if (cls == nullptr)
    return nullptr;
  return NS::Object::alloc<HostInfo>(cls);
}

HostInfo *HostInfo::init() noexcept {
  SEL s = sel_registerName("init");
  return NS::Object::sendMessage<HostInfo *>(this, s);
}

dispatch_queue_t HostInfo::backgroundQueue() noexcept {
  SEL s = sel_registerName("backgroundQueue");
  return NS::Object::sendMessage<dispatch_queue_t>(this, s);
}

NS::String *HostInfo::systemVersion() noexcept {
  SEL s = sel_registerName("systemVersion");
  return NS::Object::sendMessage<NS::String *>(this, s);
}

NS::String *HostInfo::hostName() noexcept {
  SEL s = sel_registerName("hostName");
  return NS::Object::sendMessage<NS::String *>(this, s);
}

NS::String *HostInfo::bundlePath() noexcept {
  SEL s = sel_registerName("bundlePath");
  return NS::Object::sendMessage<NS::String *>(this, s);
}

std::u8string make_u8string(NS::String *txt) {
  if (txt == nullptr)
    throw std::invalid_argument{__func__};
  size_t len = txt->lengthOfBytes(NS::UTF8StringEncoding);
  const char *ptr = txt->utf8String();
  std::u8string output{reinterpret_cast<const char8_t *>(ptr), len};
  txt->release();
  return output;
}

} // namespace experiment
