#define NS_PRIVATE_IMPLEMENTATION
#include <Foundation/Foundation.hpp> // objc/runtime.h

#include <dispatch/dispatch.h>
#include <dlfcn.h>
#include <vector>

#include "Baguette.h"

namespace experiment {

void enum_class_names(FILE *fout) noexcept {
  std::vector<Class> handles{};
  if (int count = objc_getClassList(nullptr, 0); count > 0) {
    handles.resize(count);
    count = objc_getClassList(handles.data(), count);
    if (count > 0)
      fprintf(fout, "classes:\n");
  }
  // details of the each classes
  unsigned int length = 0;
  for (objc_class *cls : handles) {
    // name
    auto name = class_getName(cls);
    fprintf(fout, " - name: %s\n", name);
    // methods
    if (Method *methods = class_copyMethodList(cls, &length); methods) {
      fprintf(fout, "   methods:\n");
      for (unsigned int i = 0; i < length; ++i) {
        Method m = methods[i];
        SEL s = method_getName(m);
        fprintf(fout, "   - \"%s\"\n", sel_getName(s));
      }
      free(methods);
    }
    // protocols
    if (Protocol **protocols = class_copyProtocolList(cls, &length);
        protocols) {
      fprintf(fout, "   protocols:\n");
      for (unsigned int i = 0; i < length; ++i) {
        Protocol *p = protocols[i];
        fprintf(fout, "   - %s\n", protocol_getName(p));
      }
      free(protocols);
    }
  }
  fprintf(fout, "\n");
}

void something(void *ctx) noexcept {
  fprintf(stdout, "%s: %p\n", __func__, pthread_self());
  auto sem = reinterpret_cast<dispatch_semaphore_t>(ctx);
  dispatch_semaphore_signal(sem);
}

uint32_t something_in_background(dispatch_queue_t queue,
                                 dispatch_semaphore_t sem) noexcept {
  fprintf(stdout, "%s: %p\n", __func__, pthread_self());
  void *ctx = sem;
  dispatch_function_t fn = &something;
  dispatch_async_f(queue, ctx, fn);
  return errno;
}

struct objc_runtime_error_category : public std::error_category {
  const char *name() const noexcept { return "objc_runtime_error_category"; }
  std::string message(int) const {
    return "";
    // return u_errorName(static_cast<UErrorCode>(ec));
  }
};

std::error_category &get_objc_runtime_error_category() noexcept {
  static objc_runtime_error_category instance{};
  return instance;
}

} // namespace experiment
