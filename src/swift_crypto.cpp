#include <Foundation/Foundation.hpp>

#include "swift_crypto.hpp"

namespace experiment {

CryptoRoutines *CryptoRoutines::alloc() noexcept {
  objc_class *cls = objc_lookUpClass("BaguetteBridge.CryptoRoutines");
  if (cls == nullptr)
    return nullptr;
  return NS::Object::alloc<CryptoRoutines>(cls);
}

CryptoRoutines *CryptoRoutines::init() noexcept {
  SEL s = sel_registerName("initAndReturnError:");
  return NS::Object::sendMessage<CryptoRoutines *>(this, s);
}

NS::Data *CryptoRoutines::hashSHA256(NS::String *text) {
  SEL s = sel_registerName("hashSHA256WithText:");
  return NS::Object::sendMessage<NS::Data *>(this, s, text);
}

} // namespace experiment
