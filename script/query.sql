# 1 view traffic engagement

CREATE OR REPLACE VIEW `havasproject.havas_data.v_ga360_traffic_engagement` AS (
  SELECT
  PARSE_DATE('%Y%m%d', date) AS date,
  channelGrouping AS channel,
  geoNetwork.country AS country,
  device.deviceCategory AS device,
  COUNT(DISTINCT fullVisitorId) AS kpi_users,
  COUNT(visitId) AS kpi_sessions,
  IFNULL(SUM(totals.pageviews), 0) AS kpi_views
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE
    _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(PARSE_DATE('%Y%m%d', '20170801'), INTERVAL 180 DAY)) AND '20170801'
  GROUP BY 1,2,3,4
  ORDER BY date
)

# 2 view acquisition channels

CREATE OR REPLACE VIEW `havasproject.havas_data.v_ga360_acquisition_channels` AS (
  SELECT
  PARSE_DATE('%Y%m%d', date) AS date,
  channelGrouping AS channel,
  geoNetwork.country AS country,
  device.deviceCategory AS device,
  COUNT(visitId) AS kpi_sessions,
  IFNULL(SUM(totals.bounces), 0) AS kpi_bounces
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE
    _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(PARSE_DATE('%Y%m%d', '20170801'), INTERVAL 180 DAY)) AND '20170801'
GROUP BY 1, 2, 3, 4
ORDER BY date
)

# 3 ecommerce performance

CREATE OR REPLACE VIEW `havasproject.havas_data.v_ga360_ecommerce_performance` AS (
  SELECT
    PARSE_DATE('%Y%m%d', date) AS date,
    channelGrouping AS channel,
    geoNetwork.country AS country,
    device.deviceCategory AS device,
    -- Metryki finansowe
    COUNT(visitId) AS kpi_sessions, -- Potrzebne w tej sekcji do wyliczenia Współczynnika Konwersji w BI
    IFNULL(SUM(totals.transactions), 0) AS kpi_transakcje,
    IFNULL(SUM(totals.transactionRevenue) / 1000000, 0) AS kpi_przychody
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE
    _TABLE_SUFFIX BETWEEN 
      FORMAT_DATE('%Y%m%d', DATE_SUB(PARSE_DATE('%Y%m%d', '20170801'), INTERVAL 180 DAY)) AND '20170801'
  GROUP BY 1, 2, 3, 4
  ORDER BY date
)
