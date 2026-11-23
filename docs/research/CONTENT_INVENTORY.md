# Reference Site Content Inventory

**Source (feature reference only):** https://archeryprotools.com/  
**Crawled:** 2026-11-23 via homepage, `/tools`, `/sitemap.xml`, formulas page, and key calculator pages.  
**Use policy:** Feature/coverage reference only. Do **not** copy branding, layout, CSS, JS, or verbatim copy into Arcus.

## Site structure

| Area | Paths |
| --- | --- |
| Hub | `/`, `/tools` |
| Formulas desk | `/archery-formulas-calculations` |
| Blog / guides | `/blog/*` (~15+ guides) |
| Legal | privacy, terms, disclaimer, cookies, affiliate, editorial |
| About / contact | `/about`, `/contact` |

Sitemap lists **60+ calculator/chart pages** under `/calculators/` plus `/foc-calculator`.

## Calculator inventory (by category)

### FOC & arrow build
| Tool | Inputs (typical) | Outputs | Formula / model (reference) |
| --- | --- | --- | --- |
| FOC | Balance point A, length L | FOC % | ATA/AMO: `((A - L/2) / L) × 100` |
| Arrow weight + FOC | GPI, length, components | Total grains, FOC estimate | Mass sum + component FOC estimate |
| Arrow weight | GPI, length, components, draw wt | Total gr, GPP, min weight | `(GPI × L) + components`; GPP = total/draw |
| FOC by spine | Spine/GPI tables | Typical FOC ranges | Chart lookup |
| Brand FOC helpers | Easton / Gold Tip / Podium-style components | FOC, weight | Same FOC formula + brand GPI refs |
| Ashby / high FOC | Heavy front mass inputs | FOC category | Same FOC; Ashby category bands |
| Point weight for FOC | Current FOC, target FOC | Point grains needed | Mass redistribution estimate |
| Arrow cut length | Draw length, rest, point type | Cut length | Fit heuristics |

### Speed & ballistics
| Tool | Inputs | Outputs | Model |
| --- | --- | --- | --- |
| Arrow speed | Ref speed/weight, new weight, efficiency | fps, m/s | `v = v_ref × √(w_ref/w) × η` |
| Bow / IBO speed | IBO, DW, DL, arrow, string extras | Estimated fps | Energy scaling from IBO baseline + shop rules of thumb |
| Speed + KE combo | As above | fps + KE | Combined |
| Arrow drop | Speed, zero distance, target distance | Drop inches | Gravity-first `½gt²` with sight height notes; drag optional |
| Trajectory | Speed, zero | Path / drop table | Extended drop model |
| Time of flight | Speed, distance | t, impact speed estimate | `t = d/v` (+ drag notes) |
| Sight pin gap | Speed, peep-pin, distances | Pin gaps | Geometry from drop |
| Shot angle | LOS distance, angle / stand height | True horizontal distance | Cosine correction |
| Crossbow speed / ballistic / range / scope | Rated speed, bolt weight, zero | Speed, drop, KE | Crossbow-specific assumptions |

### Energy & momentum
| Tool | Inputs | Outputs | Model |
| --- | --- | --- | --- |
| Kinetic energy | Weight, speed | ft-lb, J | `(gr × fps²) / 450240` |
| Momentum | Weight, speed | slug·ft/s, kg·m/s | `(gr × fps) / 225218` |
| Weight→KE / DW→KE | Sweep params | Tables | Combined speed+KE models |
| Bow efficiency | Stored vs KE | % | Approximate stored energy |
| Effective range | Speed, weight, game band | Range where KE/mom remain | Downrange energy model |
| Charts | Fixed tables | Lookup | Precomputed grids |

### Spine & tuning
| Tool | Inputs | Outputs | Model |
| --- | --- | --- | --- |
| Spine calculator | DW, length, point, cam, bow type | Spine class | Effective weight heuristic → chart band |
| Recurve / Victory / dynamic spine | Variant inputs | Spine | Separate charts / heuristics |
| Spine charts | DW bands | Spine | Static charts |
| Paper tuning chart | Tear type | Correction guidance | Diagnostic (non-numeric) |
| String length / bow length | AMO length, DL | String / bow size | AMO conventions |

### Utilities & workflow
| Tool | Notes |
| --- | --- |
| Unit converter | grains↔g, fps↔m/s, ft-lb↔J, in↔cm, etc. |
| Score calculator | End scoring |
| Setup chain assistant | Multi-metric workflow (FOC, weight, speed checks) |
| Draw length / weight | Wingspan/2.5, height charts, game recommendations |
| Let-off | Holding weight ↔ % |

### Guides / blog (educational topics to rewrite originally)
FOC how-to, KE vs momentum, spine guide, speed without chronograph, trajectory/spine, weighing arrows, parts of an arrow, draw weight for game, sight-in, range of compound, choosing arrows, calculator methodology.

## Formulas confirmed against industry sources

| Formula | Constant / statement | Citations used in Arcus |
| --- | --- | --- |
| FOC | AMO/ATA: `100 × (A − L/2) / L` | Easton FOC FAQ; AMO-standard wording |
| KE | `(grains × fps²) / 450240` | Common industry form; `450240 = 2 × 7000 × 32.16` |
| Momentum | `(grains × fps) / 225218` | `7000 × 32.174` slug conversion |
| Draw length estimate | Wingspan ÷ 2.5 | Widely taught shop estimate (confirm at full draw) |
| Speed vs mass | `v ∝ 1/√mass` from KE conservation | Physics identity under constant energy assumption |
| Spine effective weight | +4 lb/in over 28", +3 lb/25 gr over 100 gr, cam ± | Common shop heuristic; **not** a manufacturer chart substitute |

## Honest gaps / limitations (carry into product)

1. Manufacturer spine charts are proprietary; Arcus ships a **planning heuristic + empty manufacturer chart slots** filled only with publicly described banding, and always prompts users to verify on current Easton/Gold Tip/Victory/Black Eagle/Carbon Express charts.
2. Drop calculators on the reference site are gravity-first; real drag increases drop. Arcus exposes both gravity-only and a simple Cd drag model with assumptions labeled.
3. IBO→real speed is an estimate; chronograph required for truth.
4. Game KE/momentum “guidelines” are hunter rules of thumb, not laws.

## Mapping → Arcus feature modules

See `docs/product/INFORMATION_ARCHITECTURE.md`.
