#pragma once
#include <Foundation/Foundation.hpp>
#include <string>

#include <dispatch/dispatch.h>

namespace experiment {

/// @see HostInfo.swift
class HostInfo : public NS::Referencing<HostInfo> {
public:
  static HostInfo *alloc() noexcept;
  HostInfo *init() noexcept;

  dispatch_queue_t backgroundQueue() noexcept;
  NS::String *systemVersion() noexcept;
  NS::String *hostName() noexcept;
  NS::String *bundlePath() noexcept;
};

std::u8string make_u8string(NS::String *txt);

} // namespace experiment
