#pragma once
#include <Foundation/Foundation.hpp>
#include <cstdio>

namespace experiment {

/// @see CryptoRoutines.swift
class CryptoRoutines : public NS::Referencing<CryptoRoutines> {
public:
  static CryptoRoutines *alloc() noexcept;
  CryptoRoutines *init() noexcept;

  NS::Data *hashSHA256(NS::String *text);
};

} // namespace experiment
