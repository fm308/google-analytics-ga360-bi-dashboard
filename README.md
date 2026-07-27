#  Google Analytics (GA360) Data Marts & BI Infrastructure in BigQuery

##  Business Overview
This project delivers a modular, performance-optimized Data Mart architecture built directly in **Google BigQuery** using the public **Google Merchandise Store (GA360)** dataset (`bigquery-public-data.google_analytics_sample`).

The goal was to transform raw, session-level web analytics data into three focused, lightweight **SQL Views** (Data Marts) designed to feed an interactive **Power BI Dashboard** covering a 180-day reporting window.

---

##  Tech Stack & Key Concepts
* **Database:** Google BigQuery (Standard SQL)
* **Dataset:** GA360 Public Sample (`ga_sessions_*`)
* **Core Techniques:** SQL Views, Sharded Table Filtering (`_TABLE_SUFFIX`), Date Parsing, Metric Normalization, Dimensional Grouping

---

##  Architecture & Technical Highlights

1. **Sharded Table Partitioning & Cost Control:**
   * Utilized `_TABLE_SUFFIX` to dynamic filter wildcard tables (`ga_sessions_*`) for exactly a **180-day interval** ending on `2017-08-01`.
   * Executed *partition pruning* to minimize bytes scanned in BigQuery, directly reducing query compute costs.

2. **Lowest Required Granularity (Data Volume Reduction):**
   * Raw session data was aggregated across four core business dimensions required for Power BI global slicers:
     * `date` (parsed from string `%Y%m%d` to proper `DATE` type)
     * `channel` (`channelGrouping`)
     * `country` (`geoNetwork.country`)
     * `device` (`deviceCategory`)
   * By pre-aggregating metrics at this exact dimensional intersection, the rows passed to Power BI were reduced from millions to a compact, highly responsive dataset.

3. **Currency & Null Handling:**
   * Handled raw GA360 revenue scaling by dividing `totals.transactionRevenue` by `1,000,000` to convert micros to standard USD values.
   * Applied `IFNULL(..., 0)` wrappers on volatile metrics (`pageviews`, `bounces`, `transactions`, `revenue`) to ensure clean aggregation in BI tools without null-propagation issues.

---

##  Data Marts Structure (SQL Views)

### 1. `v_ga360_traffic_engagement`
Focuses on general volume and engagement trends across traffic dimensions.
* **Dimensions:** `date`, `channel`, `country`, `device`
* **Metrics:** 
  * `kpi_users` — `COUNT(DISTINCT fullVisitorId)` (Daily unique visitors)
  * `kpi_sessions` — `COUNT(visitId)`
  * `kpi_views` — `SUM(totals.pageviews)`

### 2. `v_ga360_acquisition_channels`
Designed for analyzing marketing channel quality and traffic friction.
* **Dimensions:** `date`, `channel`, `country`, `device`
* **Metrics:** 
  * `kpi_sessions` — `COUNT(visitId)`
  * `kpi_bounces` — `SUM(totals.bounces)` *(Used in BI to compute Bounce Rate)*

### 3. `v_ga360_ecommerce_performance`
Tracks monetization, financial returns, and sales efficiency.
* **Dimensions:** `date`, `channel`, `country`, `device`
* **Metrics:** 
  * `kpi_sessions` — `COUNT(visitId)` *(Used in BI as denominator for Conversion Rate)*
  * `kpi_transakcje` — `SUM(totals.transactions)`
  * `kpi_przychody` — `SUM(totals.transactionRevenue) / 1000000` *(Normalized USD)*

---

##  Repository Structure
```text
.
├── README.md
└── sql/
    ├── 01_v_ga360_traffic_engagement.sql
    ├── 02_v_ga360_acquisition_channels.sql
    └── 03_v_ga360_ecommerce_performance.sql
