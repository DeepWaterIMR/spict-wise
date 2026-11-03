# The abundance index

SPiCT consumes a series that approximates **relative** biomass over time. It does not care
whether that series is fisheries-independent or fisheries-dependent: anything with a year, a
point estimate, and a per-observation uncertainty will drive the model.

## The contract

After extraction, the index must be a data frame with:

| Column | Meaning |
|---|---|
| `year` | Numeric year. The fractional timing offset is added later, from `INDEX_TIMING` |
| `est` | Point estimate. Units are arbitrary — it is rescaled by its own mean |
| `se` | Standard error on the log scale, used to build the `stdevfacI` multiplier |

`lwr` and `upr` are used for plotting when present. If the producer gives `cv` rather than
`se`, convert once, in `R/2_prepare_index.R`, not in the document.

`R/2_prepare_index.R` writes `data/output/<stock>_index.rds` in that shape. Everything
downstream reads that file, so a change of index producer touches one script.

## What kind of index?

Ask before assuming. The shapes that turn up:

- **Survey biomass index** — design-based (a stratified mean) or model-based (GAM, sdmTMB,
  VAST) from a research bottom-trawl, beam-trawl, acoustic, or longline survey.
- **Survey abundance index** — the count-based equivalent, often per length or age class.
- **CPUE** — fisheries-dependent catch per unit effort, raw or standardised for vessel, gear,
  area, and month through a GLM, GLMM, or Tweedie sdmTMB model.
- **Composite** — several of the above combined beforehand. SPiCT also accepts multiple `obsI`
  series natively; the template wires a single index, and adding a second is a benchmark
  decision, not an update-year one.

The choice shapes everything downstream: which producer to ask, what the object looks like on
disk, and whether the extraction in `R/2_prepare_index.R` needs rewriting.

## Where the file comes from

The index is almost never produced by this project. At IMR Deep-water the pattern is one
producer repository per species or species group; for the Barents Sea redfishes that is
[**index-wise**](https://github.com/DeepWaterIMR/index-wise) driving an sdmTMB
spatiotemporal index, exported at the end of its step 4.

Ask the analyst for the URL or path of whatever produces the index for this stock, then read
it rather than guessing: which surveys or fleets are combined, the structure of the output
object, whether there are several variants to choose between, and how the file physically
arrives in `data/source/`. **Pin a commit or a tag.** An index that changed between last year's
assessment and this one, unrecorded, is indistinguishable from a stock that changed.

### When the index comes from index-wise

Step 4 writes a versioned `assessment-index.rds` handoff containing `schema_version = 1`,
`selected_name`, an `observations` data frame (`year`, `est`, `lwr`, `upr`, `se`), and metadata
for units, uncertainty, index type, timing, spatial scope, and provenance. Copy this file to
`data/source/` and set `INDEX_FILE` and `INDEX_ELEMENT` in config. The consumer checks the
selected name and timing against its configuration. Legacy named lists and data frames remain
readable; positional list selection now errors so variant changes cannot silently alter inputs.
The canonical schema is index-wise's [assessment-index
hand-off](https://github.com/DeepWaterIMR/index-wise/blob/main/knowledge/assessment-index-handoff.md).

### When it comes from anywhere else

A CPUE series is rarely a list. Rewrite the extraction in `R/2_prepare_index.R` to read
whatever the producer actually emits, and delete the list-indexing rather than wrapping a
single data frame in a list to satisfy code that expects one.

## Which variant is the assessment index?

If the producer emits several, the analyst is choosing one — record what they picked and why.
"Over 30 cm because recruitment is treated separately by gadget3" is a decision; "element 2" is
not.

## Is the index pre-smoothed?

SPiCT needs a standardised but **unsmoothed** index. It is a state-space model: biomass is a
latent state with process error (`sdb`) and the index is an observation of it with observation
error (`sdi`). It does the smoothing itself. An index that was already smoothed — a moving
average, a spline or `s(year)` on year, or a model-based index whose years borrow strength from
each other — is smoothed twice. Its observation errors are autocorrelated, which invalidates the
OSA residual tests; its inter-annual variability and standard errors are understated, so `sdi`
and `stdevfacI` are too small and the advice intervals too narrow.

Ask the producer how years are linked, and flag anything other than independent year estimates:

- **sdmTMB (index-wise)** — the assessment index should use `spatiotemporal = "iid"` with year
  as a fixed effect. An `ar1` or `rw` field, `s(year)`, or `time_varying` pre-smooths it. See
  index-wise's [assessment
  constraint](https://github.com/DeepWaterIMR/index-wise/blob/main/knowledge/model-selection.md#the-assessment-constraint-on-the-spatiotemporal-structure).
- **VAST** — the equivalent is IID spatiotemporal variation with year intercepts as fixed
  effects, not an autoregressive structure on them.
- **GLM/GAM CPUE** — year as a factor, not a smooth.
- **Design-based** — unsmoothed by construction; check nobody averaged it afterwards.

Standardisation for vessel, gear, area, or environment is wanted; smoothing the time series is
not. If the index is pre-smoothed, ask for the unsmoothed variant before fitting. If none can be
had, record that in the memory file and expect Ljung–Box failures in the OSA residuals. Do not
combine several surveys by smoothing them over time; combine them in the spatiotemporal model,
or give SPiCT several `obsI` series.

## Timing within the year

`INDEX_TIMING` is the fraction of the year the index observation refers to, and it must match
when the survey actually runs. A winter survey entered at 0.5 shifts the biomass trajectory
half a year against the catches and shows up as a stubborn pattern in the OSA residuals.

## Record it

Write `ai/memory/index-data-sources.md` with: the index type; the producer repository or script
and the pinned commit; which surveys, years, gear, and area (or which fleet and effort metric);
which variant was chosen and why; how years are linked in the producer's model (e.g. `iid` +
year effect) and whether the series is pre-smoothed; the structural shape on disk and whether
the extraction needed editing; the timing offset and its justification; and how the file gets
into `data/source/`.
