#include <Foundation/Foundation.hpp>

#include "swift_decoder.hpp"

namespace experiment {

DecoderRoutines *DecoderRoutines::alloc() noexcept {
  objc_class *cls = objc_lookUpClass("BaguetteBridge.DecoderRoutines");
  if (cls == nullptr)
    return nullptr;
  return NS::Object::alloc<DecoderRoutines>(cls);
}

DecoderRoutines *DecoderRoutines::init() noexcept {
  SEL s = sel_registerName("init");
  return NS::Object::sendMessage<DecoderRoutines *>(this, s);
}

void DecoderRoutines::print2() {
  SEL s = sel_registerName("print2");
  return NS::Object::sendMessage<void>(this, s);
}

void DecoderRoutines::print2WithText(NS::String *text) {
  SEL s = sel_registerName("print2WithText:error:");
  return NS::Object::sendMessage<void>(this, s, text);
}

} // namespace experiment
