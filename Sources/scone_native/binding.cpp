/**
 * @file binding.cpp
 * @author github.com/luncliff (luncliff@gmail.com)
 * @see https://gist.github.com/luncliff/1fedae034c001a460e9233ecf0afc25b
 */
#include <dispatch/dispatch.h>
#include <experimental/coroutine>
#if !defined(FMT_HEADER_ONLY)
#define FMT_HEADER_ONLY
#endif
#include <fmt/chrono.h>
#if !defined(SPDLOG_HEADER_ONLY)
#define SPDLOG_HEADER_ONLY
#endif
#include <spdlog/sinks/stdout_sinks.h>
#include <spdlog/spdlog.h>

using std::experimental::coroutine_handle;
using std::experimental::noop_coroutine;
using std::experimental::suspend_always;
using std::experimental::suspend_never;

struct log_context_t final {
  const char *name = "scone_native";
  FILE *fout = stdout;

public:
  log_context_t() noexcept { configure(fout, name); }
  ~log_context_t() noexcept {
    if (auto logger = spdlog::get(name); logger)
      logger->flush();
  }

  static void configure(FILE *fout, const char *name) {
    using sink_t =
        spdlog::sinks::stdout_sink_base<spdlog::details::console_nullmutex>;
    auto sink = std::make_shared<sink_t>(fout);
    auto logger = std::make_shared<spdlog::logger>(name, sink);
    logger->set_level(spdlog::level::debug);
    logger->set_pattern("%T %f [%l] %6t %v");
    logger->set_error_handler(on_error);
    spdlog::set_default_logger(logger);
  }

  /// @brief When we come here, we can't format. Just report messages
  static void on_error(const std::string &message) {
    fprintf(stderr, "%s\n", message.c_str());
  }
};

log_context_t logging{};

void sink_exception(std::exception_ptr &&exp) noexcept {
  try {
    std::rethrow_exception(exp);
  } catch (const std::exception &ex) {
    spdlog::source_loc location{};
    spdlog::log(location, spdlog::level::err, "{}", ex.what());
  }
}

void resume_once(void *ptr) noexcept {
  auto task = coroutine_handle<void>::from_address(ptr);
  if (task.done())
    // probably because of the logic error
    return spdlog::warn("final-suspended coroutine_handle");
  task.resume();
}

/**
 * @see C++/WinRT `winrt::fire_and_forget`
 */
struct fire_and_forget final {
  struct promise_type final {
    constexpr suspend_never initial_suspend() noexcept { return {}; }
    constexpr suspend_never final_suspend() noexcept { return {}; }
    void unhandled_exception() noexcept {
      sink_exception(std::current_exception());
    }
    constexpr void return_void() noexcept {}
    fire_and_forget get_return_object() noexcept {
      return fire_and_forget{*this};
    }
  };

  explicit fire_and_forget([[maybe_unused]] promise_type &) noexcept {}
};

/**
 * @brief Forward the `coroutine_handle`(job) to `dispatch_queue_t`
 * @see dispatch_async_f
 * @see
 * https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html
 */
struct queue_awaitable_t final {
  dispatch_queue_t queue;

public:
  /// @brief true if `queue` is nullptr, resume immediately
  constexpr bool await_ready() const noexcept { return queue == nullptr; }
  /// @see dispatch_async_f
  void await_suspend(coroutine_handle<void> coro) noexcept {
    dispatch_async_f(queue, coro.address(), resume_once);
  }
  constexpr void await_resume() const noexcept {}
};
static_assert(std::is_nothrow_copy_constructible_v<queue_awaitable_t> == true);
static_assert(std::is_nothrow_copy_assignable_v<queue_awaitable_t> == true);
static_assert(std::is_nothrow_move_constructible_v<queue_awaitable_t> == true);
static_assert(std::is_nothrow_move_assignable_v<queue_awaitable_t> == true);

fire_and_forget print_message_async(dispatch_queue_t queue,
                                    const char *message) {
  if (queue)
    co_await queue_awaitable_t{queue};
  else
    co_await suspend_never{};
  spdlog::debug(message);
}
