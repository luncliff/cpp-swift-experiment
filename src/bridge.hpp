#pragma once
#include <cstdio>
#include <system_error>

namespace experiment {

void enum_class_names(FILE *fout) noexcept;

std::error_category &get_objc_runtime_error_category() noexcept;

} // namespace experiment
