# 隐私政策 — SRT 字幕翻译器 (SRT Translator)

生效日期：2025-11-05

## 中文版摘要

本应用会将您上传的字幕文本发送给第三方 AI 服务 Deepseek（https://platform.deepseek.com）以进行翻译。您的 Deepseek API 密钥仅保存在设备本地（@AppStorage / UserDefaults），不会上传到开发者的服务器。本应用不收集联系人、位置或其他个人识别信息。若启用诊断或崩溃收集，会在设置中明确告知并征得同意。

## 我们收集/处理的数据
- 用户内容（字幕文本）：当您上传 .srt 文件时，字幕文本将被发送到 Deepseek 用于翻译。
- 应用设置：Deepseek API 密钥，保存在设备本地，供后续调用使用。
- 诊断/崩溃（可选）：仅在您允许时收集，以便改进应用。

## 数据用途
- 将字幕文本发送给 Deepseek，用于生成翻译并返回给您。
- 本地保存 API 密钥，避免重复输入。

## 第三方与共享
- 我们会将字幕文本发送给 Deepseek（第三方），翻译处理由其负责。请参阅 Deepseek 的隐私政策以了解其数据处理与保留策略。
- 我们不会将您的字幕或密钥出售或共享给广告商或其他第三方用于营销。

## 数据保留
- 本地导出的双语 SRT 文件保存在您的设备，您可以随时删除。
- Deepseek 侧的数据保留由 Deepseek 决定，请参阅其隐私政策。

## 用户权利
- 删除本地文件：您可以在设备上删除任意导出文件。
- 清除 API 密钥：在设置中可清除已保存的 API 密钥。
- 如需删除 Deepseek 侧的数据，请联系 Deepseek 支持。

## 安全措施
- 与 Deepseek 的通信使用 HTTPS。
- 使用 SecureField 输入 API 密钥，保存在本地 UserDefaults (@AppStorage)。
- 不在应用中硬编码第三方密钥。

## 联系方式
如需帮助或提出隐私相关请求，请联系：{您的支持页面或邮箱}

---

# Privacy Policy — SRT Translator (English)

Effective date: 2025-11-05

## Summary
This app sends subtitle text you upload to Deepseek (https://platform.deepseek.com) for translation. Your Deepseek API key is stored locally on your device (@AppStorage/UserDefaults) and is not sent to the developer's servers. The app does not collect contacts, location, or other personal identifiers by default. Diagnostic/crash reporting is disabled unless you enable it.

## Data Collected / Processed
- User Content (subtitle text): Sent to Deepseek for translation when uploading .srt files.
- App settings: Deepseek API key (stored locally for convenience).
- Diagnostics/Crash logs (optional): Collected only with user consent.

## Purpose
- Send subtitle text to Deepseek to obtain translations and return results to the user.
- Store API key locally so users do not need to re-enter it each time.

## Third Parties
- Translations are performed by Deepseek. Please consult Deepseek's privacy policy for details on their processing and retention rules.
- We do not sell or share your subtitles or API keys to advertisers or third parties for marketing purposes.

## Retention
- Local bilingual SRT files remain on the device until you delete them.
- Deepseek's retention policy applies to data processed by Deepseek.

## User Rights
- Remove exported files locally at any time.
- Clear stored API key via the app settings.
- For removal of data on Deepseek, contact Deepseek support.

## Security
- All communication to Deepseek uses HTTPS.
- API keys are entered via SecureField and stored locally.
- No hardcoded third-party keys are included in the app binary.

## Contact
For privacy requests or support: {support URL or email}
