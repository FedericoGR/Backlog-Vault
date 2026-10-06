# Visual regression checks

Run `flutter test test/visual` to compare the real production widgets at
1440×960 and 900×800. To intentionally refresh references, run
`flutter test test/visual --update-goldens` and inspect the resulting PNGs.

Provider overrides isolate all records, cover bytes, language and credential
presence. No user database or external service is used. Covers are synthetic
graphics generated in memory. The included Apache-licensed Roboto font makes
text deterministic across hosts; it is registered under the test theme's font
family only, and does not change the production desktop font or dependencies.
