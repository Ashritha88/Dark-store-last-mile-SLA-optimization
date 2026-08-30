/* =========================================================================
   DARK STORE & LAST-MILE SLA OPTIMIZATION
   SQL ANALYSIS PACK

   Tables:
     orders (dark_store_orders.csv)       -- order-level fact table
     dark_stores (dark_store_master.csv) -- store dimension

   Analysis Areas:
     1. Overall SLA Compliance
     2. Peak vs Non-Peak Performance
     3. Dark Store Performance
     4. Hourly SLA Analysis
     5. Pareto Delay Analysis
     6. Fishbone Root-Cause Analysis
     7. Weekday vs Weekend Performance
     8. Rider-Level Performance
     9. Delay Reason by Time Period
     10. Daily SLA Trend
     11. Impact Sizing

   Load both CSVs into your SQL environment using the column names
   exactly as they appear in the CSV headers.
   ========================================================================= */


/* -------------------------------------------------------------------------
   0. TABLE CREATION
   Reference DDL - adjust data types according to your SQL engine
   ------------------------------------------------------------------------- */

CREATE TABLE dark_stores (
    Dark_Store_ID     VARCHAR(10) PRIMARY KEY,
    City              VARCHAR(50),
    Zone              VARCHAR(50),
    Store_Size_sqft   INT,
    Rider_Fleet_Size  INT,
    Avg_SKU_Count     INT
);


CREATE TABLE orders (
    Order_ID              VARCHAR(20) PRIMARY KEY,
    Dark_Store_ID         VARCHAR(10),
    City                  VARCHAR(50),
    Zone                  VARCHAR(50),
    Order_Date            DATE,
    Order_Timestamp       DATETIME,
    Order_Hour            INT,
    Day_Type              VARCHAR(10),
    Time_Period           VARCHAR(10),   -- Peak / Non-Peak
    Promised_SLA_Min      DECIMAL(5,2),
    Actual_Delivery_Min   DECIMAL(5,2),
    SLA_Met               CHAR(1),       -- Y / N
    Delay_Reason          VARCHAR(60),
    Delay_Category        VARCHAR(20),   -- Fishbone bucket
    Distance_KM           DECIMAL(4,2),
    Item_Count            INT,
    Order_Value_INR       DECIMAL(8,2),
    Rider_ID              VARCHAR(10),

    FOREIGN KEY (Dark_Store_ID)
        REFERENCES dark_stores(Dark_Store_ID)
);


/* -------------------------------------------------------------------------
   1. OVERALL SLA COMPLIANCE
   Calculates total orders, SLA-met orders and overall SLA percentage.
   ------------------------------------------------------------------------- */

SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN SLA_Met = 'Y' THEN 1
            ELSE 0
        END
    ) AS sla_met_orders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN SLA_Met = 'Y' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS sla_compliance_pct

FROM orders;


/* -------------------------------------------------------------------------
   2. SLA COMPLIANCE: PEAK vs NON-PEAK
   Compares SLA performance during peak and non-peak periods.
   ------------------------------------------------------------------------- */

SELECT
    Time_Period,

    COUNT(*) AS total_orders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN SLA_Met = 'Y' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS sla_pct,

    ROUND(
        AVG(Actual_Delivery_Min),
        2
    ) AS avg_delivery_min,

    ROUND(
        AVG(
            CASE
                WHEN SLA_Met = 'N'
                THEN Actual_Delivery_Min
            END
        ),
        2
    ) AS avg_delivery_min_breaches

FROM orders

GROUP BY Time_Period

ORDER BY sla_pct;


/* -------------------------------------------------------------------------
   3. SLA COMPLIANCE BY DARK STORE
   Identifies relatively poor-performing stores.
   ------------------------------------------------------------------------- */

SELECT
    o.Dark_Store_ID,
    ds.City,
    ds.Zone,
    ds.Rider_Fleet_Size,

    COUNT(*) AS total_orders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN o.SLA_Met = 'Y' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS sla_pct,

    ROUND(
        AVG(o.Actual_Delivery_Min),
        2
    ) AS avg_delivery_min

FROM orders o

JOIN dark_stores ds
    ON ds.Dark_Store_ID = o.Dark_Store_ID

GROUP BY
    o.Dark_Store_ID,
    ds.City,
    ds.Zone,
    ds.Rider_Fleet_Size

ORDER BY sla_pct ASC;


/* -------------------------------------------------------------------------
   4. HOURLY SLA ANALYSIS
   Identifies hours with relatively lower SLA performance.
   ------------------------------------------------------------------------- */

SELECT
    Order_Hour,

    COUNT(*) AS total_orders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN SLA_Met = 'Y' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS sla_pct

FROM orders

GROUP BY Order_Hour

ORDER BY Order_Hour;


/* -------------------------------------------------------------------------
   5. PARETO ANALYSIS OF DELAY REASONS
   Ranks delay reasons by breach count and cumulative percentage.
   ------------------------------------------------------------------------- */

WITH breach_counts AS (

    SELECT
        Delay_Reason,
        Delay_Category,
        COUNT(*) AS breach_count

    FROM orders

    WHERE SLA_Met = 'N'

    GROUP BY
        Delay_Reason,
        Delay_Category
),

totals AS (

    SELECT
        SUM(breach_count) AS total_breaches

    FROM breach_counts
)

SELECT
    b.Delay_Reason,
    b.Delay_Category,
    b.breach_count,

    ROUND(
        100.0 *
        b.breach_count /
        t.total_breaches,
        2
    ) AS pct_of_breaches,

    ROUND(
        100.0 *
        SUM(b.breach_count) OVER (
            ORDER BY b.breach_count DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) / t.total_breaches,
        2
    ) AS cumulative_pct

FROM breach_counts b

CROSS JOIN totals t

ORDER BY b.breach_count DESC;


/* -------------------------------------------------------------------------
   6. FISHBONE CATEGORY ROLL-UP
   Groups SLA breaches into root-cause categories.
   ------------------------------------------------------------------------- */

SELECT
    Delay_Category,

    COUNT(*) AS breach_count,

    ROUND(
        100.0 *
        COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_breaches

FROM orders

WHERE SLA_Met = 'N'

GROUP BY Delay_Category

ORDER BY breach_count DESC;


/* -------------------------------------------------------------------------
   7. WEEKDAY vs WEEKEND SLA PERFORMANCE
   Compares SLA performance by day type and time period.
   ------------------------------------------------------------------------- */

SELECT
    Day_Type,
    Time_Period,

    COUNT(*) AS total_orders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN SLA_Met = 'Y' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS sla_pct

FROM orders

GROUP BY
    Day_Type,
    Time_Period

ORDER BY
    Day_Type,
    Time_Period;


/* -------------------------------------------------------------------------
   8. RIDER-LEVEL PERFORMANCE
   Identifies relatively low-performing rider/store combinations.
   Only considers riders handling at least 20 orders.
   ------------------------------------------------------------------------- */

SELECT
    Dark_Store_ID,
    Rider_ID,

    COUNT(*) AS orders_handled,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN SLA_Met = 'Y' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS sla_pct

FROM orders

GROUP BY
    Dark_Store_ID,
    Rider_ID

HAVING COUNT(*) >= 20

ORDER BY sla_pct ASC

LIMIT 20;


/* -------------------------------------------------------------------------
   9. DELAY REASON MIX: PEAK vs NON-PEAK
   Examines whether major delay reasons differ by time period.
   ------------------------------------------------------------------------- */

SELECT
    Time_Period,
    Delay_Reason,

    COUNT(*) AS breach_count

FROM orders

WHERE SLA_Met = 'N'

GROUP BY
    Time_Period,
    Delay_Reason

ORDER BY
    Time_Period,
    breach_count DESC;


/* -------------------------------------------------------------------------
   10. DAILY SLA TREND
   Calculates daily order volume and SLA percentage.
   Can be used for trend/run-chart analysis in Excel.
   ------------------------------------------------------------------------- */

SELECT
    Order_Date,

    COUNT(*) AS total_orders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN SLA_Met = 'Y' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS sla_pct

FROM orders

GROUP BY Order_Date

ORDER BY Order_Date;


/* -------------------------------------------------------------------------
   11. IMPACT SIZING
   Estimates the contribution of selected major delay reasons
   to the overall order volume.
   ------------------------------------------------------------------------- */

SELECT
    Delay_Reason,

    COUNT(*) AS breach_count,

    ROUND(
        100.0 *
        COUNT(*) /
        (
            SELECT COUNT(*)
            FROM orders
        ),
        2
    ) AS pct_of_all_orders

FROM orders

WHERE SLA_Met = 'N'

AND Delay_Reason IN (
    'Picker Unavailable / Understaffed',
    'Rider Unavailable at Dispatch'
)

GROUP BY Delay_Reason;
