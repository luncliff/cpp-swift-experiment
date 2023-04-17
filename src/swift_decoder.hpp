#pragma once
#include <Foundation/Foundation.hpp>
#include <cstdio>

namespace experiment {

/// @see DecoderRoutines.swift
class DecoderRoutines : public NS::Referencing<DecoderRoutines> {
public:
  static DecoderRoutines *alloc() noexcept;
  DecoderRoutines *init() noexcept;

  void print2();
  void print2WithText(NS::String *text);
};

} // namespace experiment
