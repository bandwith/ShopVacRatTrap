#pragma once
// Minimal host stubs of ESPHome logging macros for standalone unit tests.
#define ESP_LOGI(tag, ...) ((void)0)
#define ESP_LOGW(tag, ...) ((void)0)
#define ESP_LOGE(tag, ...) ((void)0)
#define ESP_LOGCONFIG(tag, ...) ((void)0)
