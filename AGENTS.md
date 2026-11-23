# Arcus — agent notes

You are building **Arcus**, an offline-first Flutter archery calculator app.

## Rules

- Use `packages/archery_engine` for all math. Never put formulas in widgets.
- Do not copy branding, layout, or verbatim text from archeryprotools.com.
- Every calculator result must show formula, steps, assumptions, limitations, safety, citation.
- Keep UI strings in `AppStrings` / future ARB files.
- Ads stay behind `AdService` with `adsEnabled = false` until real AdMob IDs + consent exist.
- Prefer Riverpod + GoRouter patterns already in the tree.

## Commands

```bash
cd packages/archery_engine && dart test
cd apps/arcus && flutter analyze && flutter test
```
