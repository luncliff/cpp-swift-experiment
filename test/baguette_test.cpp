/**
 * @see https://developer.apple.com/documentation/objectivec/1418579-objc_getclasslist?language=objc
 * @see https://developer.apple.com/documentation/objectivec/1418760-objc_lookupclass
 * @see https://medium.com/codex/swift-c-callback-interoperability-6d57da6c8ee6
 * @see https://developer.apple.com/documentation/objectivec/objective-c_runtime?language=objc
 * @see xcrun swift-demangle "s10Foundation11DecoderRoutinesCMa"
 */
#include "swift_crypto.hpp"
#include "swift_decoder.hpp"
#include "swift_hostinfo.hpp"

#include <cstdio>
#include <memory>
#include <span>
#include <sys/utsname.h>

namespace experiment {

extern void enum_class_names(FILE *fout) noexcept;

/// @see HostInfo.swift
class AsyncRoutines : public NS::Referencing<AsyncRoutines> {
public:
  static AsyncRoutines *alloc() noexcept {
    objc_class *cls = objc_lookUpClass("BaguetteBridge.AsyncRoutines");
    if (cls == nullptr)
      return nullptr;
    return NS::Object::alloc<AsyncRoutines>(cls);
  }
  AsyncRoutines *init() noexcept {
    SEL s = sel_registerName("init");
    return NS::Object::sendMessage<AsyncRoutines *>(this, s);
  }

  void scheduleTask() noexcept {
    SEL s = sel_registerName("scheduleTask");
    return NS::Object::sendMessage<void>(this, s);
  }
};

} // namespace experiment

void test_async_task() noexcept(false) {
  using namespace experiment;
  auto helper = AsyncRoutines::alloc();
  if (helper == nullptr)
    throw std::runtime_error{__func__};
  helper = helper->init();

  helper->scheduleTask();
  helper->release();
}

void test_hostinfo() noexcept(false) {
  using namespace experiment;
  auto info = HostInfo::alloc();
  if (info == nullptr)
    throw std::runtime_error{__func__};
  info = info->init();

  dispatch_qos_class_t qos =
      dispatch_queue_get_qos_class(info->backgroundQueue(), nullptr);

  std::u8string value = make_u8string(info->systemVersion());
  value = make_u8string(info->hostName());
  value = make_u8string(info->bundlePath());
  info->release();

  NS::Bundle *bundle = NS::Bundle::mainBundle();
  if (auto ident = bundle->bundleIdentifier(); ident)
    value = make_u8string(ident);
  value = make_u8string(bundle->resourcePath());
  auto ref_count = bundle->retainCount();
  bundle->release();
}

void test_decoder() noexcept(false) {
  using namespace experiment;
  auto decoder = DecoderRoutines::alloc();
  if (decoder == nullptr)
    throw std::runtime_error{__func__};
  decoder = decoder->init();
  decoder->print2();
  NS::String *text =
      NS::String::string(R"( {"name":"c++" } )", NS::UTF8StringEncoding);
  decoder->print2WithText(text);
  text->release();
  decoder->release();
}

void test_crypto() noexcept(false) {
  using namespace experiment;
  auto crypto = CryptoRoutines::alloc();
  if (crypto == nullptr)
    throw std::runtime_error{__func__};
  crypto = crypto->init();
  NS::String *text = NS::String::string(R"(
"국민경제의 발전을 위한 중요정책의 수립에 관하여 대통령의 자문에 응하기 위하여 국민경제자문회의를 둘 수 있다." - 국민경제자문회의법
)",
                                        NS::UTF8StringEncoding);
  NS::Data *hash = crypto->hashSHA256(text);
  auto hashview = std::span{reinterpret_cast<std::byte *>(hash->mutableBytes()),
                            hash->length()};

  text->release();
  hash->release();
  crypto->release();
}

int main(int argc, char *argv[]) {
  {
    auto fp = std::unique_ptr<FILE, int (*)(FILE *)>{
        fopen("classes.yaml", "wb"), &fclose};
    experiment::enum_class_names(fp.get());
  }
  try {
    test_hostinfo();
    test_decoder();
    test_crypto();
    test_async_task();
  } catch (const std::exception &ex) {
    fprintf(stderr, "%s\n", ex.what());
    return EXIT_FAILURE;
  }
  return 0;
}
