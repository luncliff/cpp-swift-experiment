#pragma once // module;
#include <cstdio>
#include <system_error>

/// @todo C++ 20 Modules support in AppleClang
namespace experiment {

void enum_class_names(FILE *fout) noexcept;

std::error_category &get_objc_runtime_error_category() noexcept;

} // namespace experiment
