  # increment / release-only-decrement-with-no-fence bug entirely. Same fix
  # as always: relaxed increment, release decrement, explicit acquire fence
  # before delete on the thread that observes the count reach zero.
  foreach(DXVK_PATCH_NAME dxvk-android.patch dxvk-ios.patch dxvk-vulkan11-adaptive.patch dxvk-resource-refcount-memory-order.patch dxvk-mali-clip-distance.patch dxvk-mali-g76-robustness2-optional.patch dxvk-android-missing-fallback-extensions.patch dxvk-mali-g76-legacy-barrier-fallback.patch dxvk-mali-g76-semaphore-fn-fallback.patch dxvk-mali-g76-4444-format.patch dxvk-mali-g52-bgra-texture-swizzle-test.patch dxvk-mali-g76-copy-commands2.patch dxvk-mali-g76-legacy-copy-fallback.patch dxvk-mali-g76-legacy-render-pass.patch dxvk-mali-g76-composite-alpha.patch dxvk-mali-g76-vertex-buffer-stride-fallback.patch dxvk-mali-g76-extended-dynamic-state.patch dxvk-mali-g76-dynamic-state-fallback.patch dxvk-mali-g76-demote-to-helper-fallback.patch dxvk-mali-g76-null-descriptor-fallback.patch dxvk-mali-g76-swapchain-blitter-legacy-renderpass.patch dxvk-mali-g76-blitter-pipeline-legacy-renderpass.patch dxvk-mali-g76-blitter-null-descriptor-fallback.patch dxvk-mali-g76-format-properties3-fallback.patch dxvk-mali-g76-hud-image-legacy-renderpass.patch dxvk-mali-g76-hud-stderr-log.patch dxvk-composite-alpha-log.patch dxvk-android-force-opaque-alpha.patch dxvk-refcount-memory-order-audit.patch dxvk-gpu-event-second-class-refcount-memory-order.patch)
    execute_process(
      COMMAND git -C "${DXVK_LOCAL_FORK_DIR}" apply --reverse --check "${CMAKE_SOURCE_DIR}/Patches/${DXVK_PATCH_NAME}"
      RESULT_VARIABLE DXVK_PATCH_ALREADY_APPLIED
      ERROR_QUIET)
    if(NOT DXVK_PATCH_ALREADY_APPLIED EQUAL 0)
      # Some patches touch code that a later patch also touches nearby;
      # the surrounding 3-line context can drift just enough that the
      # exact-context idempotency check above no longer matches even
      # though the patch's actual content is present. Retry with a
      # smaller context window (git's own -C flag) before concluding the
      # patch genuinely isn't applied yet.
      execute_process(
        COMMAND git -C "${DXVK_LOCAL_FORK_DIR}" apply --reverse --check -C1 "${CMAKE_SOURCE_DIR}/Patches/${DXVK_PATCH_NAME}"
        RESULT_VARIABLE DXVK_PATCH_ALREADY_APPLIED
        ERROR_QUIET)
    endif()
    if(NOT DXVK_PATCH_ALREADY_APPLIED EQUAL 0)
      execute_process(
        COMMAND git -C "${DXVK_LOCAL_FORK_DIR}" apply "${CMAKE_SOURCE_DIR}/Patches/${DXVK_PATCH_NAME}"
        RESULT_VARIABLE DXVK_PATCH_RESULT)
      if(NOT DXVK_PATCH_RESULT EQUAL 0)
        execute_process(
          COMMAND git -C "${DXVK_LOCAL_FORK_DIR}" apply -C1 "${CMAKE_SOURCE_DIR}/Patches/${DXVK_PATCH_NAME}"
          RESULT_VARIABLE DXVK_PATCH_RESULT)
      endif()
      if(NOT DXVK_PATCH_RESULT EQUAL 0)
        message(FATAL_ERROR "Failed to apply Patches/${DXVK_PATCH_NAME} to references/fbraz3-dxvk — the Android DXVK build requires it.")
      endif()
      message(STATUS "DXVK Android: applied Patches/${DXVK_PATCH_NAME}")
    else()
      message(STATUS "DXVK Android: Patches/${DXVK_PATCH_NAME} already applied")
    endif()
  endforeach()
