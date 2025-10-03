# ==============================================================
# STOCK MARKET SQL QUERIES (stock_market database)
# Dataset: national_stock
# ==============================================================

# 1. DATABASE & TABLE SETUP

# CREATE DATABASE stock_market;
 USE stock_market;

# ==============================================================
# 2. BASIC QUERIES (DQL – SELECT)
# ==============================================================

# 2.1 List all stock symbols and their last traded price (LTP)
SELECT Symbol, LTP
FROM national_stock;

# 2.2 Top 10 stocks with highest trading volume
SELECT *
FROM national_stock
ORDER BY `Volume (lacs)` DESC
LIMIT 10;

# 2.3 Classify stocks as gainers or losers based on % Chng
SELECT Symbol, `% Chng`,
    CASE
        WHEN `% Chng` >= 0 THEN 'Gainer'
        ELSE 'Loser'
    END AS stock_change
FROM national_stock;

# 2.4 Company with the highest turnover
SELECT Symbol, `Turnover (crs.)`
FROM national_stock
WHERE `Turnover (crs.)` = (
    SELECT MAX(`Turnover (crs.)`) 
    FROM national_stock
);

# 2.5 Companies where LTP is higher than the opening price
SELECT Symbol, LTP
FROM national_stock
WHERE LTP > Open;

# ==============================================================
# 3. AGGREGATIONS & GROUPING
# ==============================================================

# 3.1 Average daily change (Chng) across all stocks
SELECT AVG(Chng) AS average_daily_change
FROM national_stock;

# 3.2 Total turnover of all companies
SELECT SUM(`Turnover (crs.)`) AS total_turnover
FROM national_stock;

# 3.3 Average volume traded across all companies
SELECT AVG(`Volume (lacs)`) AS average_volume_traded
FROM national_stock;

# 3.4 Stocks with maximum and minimum 365-day % change
SELECT Symbol, `365 d % chng`
FROM national_stock
WHERE `365 d % chng` = (SELECT MAX(`365 d % chng`) FROM national_stock)
   OR `365 d % chng` = (SELECT MIN(`365 d % chng`) FROM national_stock);

# 3.5 Rank stocks by 30-day % change (descending)
SELECT Symbol, `30 d % chng`
FROM national_stock
ORDER BY `30 d % chng` DESC;

# 3.6 Companies with volume > 5x average volume
SELECT Symbol, `Volume (lacs)`
FROM national_stock
WHERE `Volume (lacs)` > 5 * (SELECT AVG(`Volume (lacs)`) FROM national_stock);

# 3.7 Average LTP of top 20 companies by turnover
SELECT AVG(LTP) AS average_ltp
FROM (
    SELECT LTP, `Turnover (crs.)`
    FROM national_stock
    ORDER BY `Turnover (crs.)` DESC
    LIMIT 20
) AS top_20_traded;

# 3.8 Company with maximum 52w high-low difference (most volatile)
SELECT Symbol, `52w H`, `52w L`, (`52w H` - `52w L`) AS difference_52w
FROM national_stock
ORDER BY difference_52w DESC
LIMIT 1;

# ==============================================================
# 4. ADVANCED SQL QUERIES
# ==============================================================

# 4.1 Top 10 companies with highest 365-day % change
SELECT *
FROM national_stock
ORDER BY `365 d % chng` DESC
LIMIT 10;

# 4.2 Bottom 10 companies by 30-day % change
SELECT *
FROM national_stock
ORDER BY `30 d % chng` ASC
LIMIT 10;

# 4.3 Companies at 52-week high
SELECT Symbol, LTP, `52w H`
FROM national_stock
WHERE LTP = `52w H`;

# 4.4 Companies at 52-week low
SELECT Symbol, LTP, `52w L`
FROM national_stock
WHERE LTP = `52w L`;

# 4.5 Short-term recovery stocks (30d positive, 365d negative)
SELECT Symbol, `30 d % chng`, `365 d % chng`
FROM national_stock
WHERE `30 d % chng` >= 0
  AND `365 d % chng` <= 0;

# 4.6 Company with highest average daily turnover per unit volume
SELECT Symbol, AVG(`Turnover (crs.)` / `Volume (lacs)`) AS avg_turnover_per_unit
FROM national_stock
GROUP BY Symbol
ORDER BY avg_turnover_per_unit DESC
LIMIT 1;

# 4.7 Data inconsistency check: Chng > 0 but % Chng < 0
SELECT Symbol, Chng, `% Chng`
FROM national_stock
WHERE Chng > 0
  AND `% Chng` < 0;

# 4.8 Stocks gaining >10% in 30 days but down in 365 days
SELECT Symbol, `30 d % chng`, `365 d % chng`
FROM national_stock
WHERE `30 d % chng` > 10
  AND `365 d % chng` < 0;

# 4.9 % difference between LTP and 52-week high
SELECT Symbol, LTP, `52w H`,
       ROUND(((LTP - `52w H`) / `52w H`) * 100, 2) AS diff_LTP_52wH
FROM national_stock;

# 4.10 % difference between LTP and 52-week low
SELECT Symbol, LTP, `52w L`,
       ROUND(((LTP - `52w L`) / `52w L`) * 100, 2) AS diff_LTP_52wL
FROM national_stock;

# ==============================================================
# 5. ADVANCED SELF-JOIN QUERIES
# ==============================================================

# 5.1 Pairs of stocks whose LTPs are within 5% of each other
SELECT 
    a.Symbol AS stock_A,
    b.Symbol AS stock_B,
    a.LTP AS LTP_A,
    b.LTP AS LTP_B,
    ROUND((ABS(a.LTP - b.LTP) / a.LTP) * 100, 2) AS difference_percent
FROM national_stock a
JOIN national_stock b
    ON a.Symbol < b.Symbol
WHERE ABS(a.LTP - b.LTP) <= 0.05 * a.LTP;

# 5.2 Pairs where one is a gainer and the other a loser
SELECT
    a.Symbol AS stock_A,
    b.Symbol AS stock_B,
    a.`% Chng` AS gainer,
    b.`% Chng` AS loser
FROM national_stock a
JOIN national_stock b
    ON a.Symbol < b.Symbol
WHERE a.`% Chng` > 0
  AND b.`% Chng` < 0;

# 5.3 Stock pairs: higher volume but lower turnover
SELECT 
    a.Symbol AS stock_A,
    b.Symbol AS stock_B,
    a.`Volume (lacs)` AS Volume_A,
    a.`Turnover (crs.)` AS Turnover_A,
    b.`Volume (lacs)` AS Volume_B,
    b.`Turnover (crs.)` AS Turnover_B
FROM national_stock a
JOIN national_stock b
    ON a.Symbol < b.Symbol
WHERE a.`Volume (lacs)` > b.`Volume (lacs)`
  AND a.`Turnover (crs.)` < b.`Turnover (crs.)`;

# 5.4 Stock pairs trading within 10% of their 52-week high
SELECT 
    a.Symbol AS stock_A,
    b.Symbol AS stock_B,
    a.LTP AS LTP_A,
    a.`52w H` AS high_A,
    b.LTP AS LTP_B,
    b.`52w H` AS high_B
FROM national_stock a
JOIN national_stock b
    ON a.Symbol < b.Symbol
WHERE a.LTP >= a.`52w H` - 0.10 * a.`52w H`
  AND b.LTP >= b.`52w H` - 0.10 * b.`52w H`;

# 5.5 Stock pairs where value traded of one is at least double the other
SELECT
    a.Symbol AS stock_A,
    b.Symbol AS stock_B,
    a.LTP * a.`Volume (lacs)` AS Value_A,
    b.LTP * b.`Volume (lacs)` AS Value_B
FROM national_stock a
JOIN national_stock b
    ON a.Symbol < b.Symbol
WHERE a.LTP * a.`Volume (lacs)` >= 2 * b.LTP * b.`Volume (lacs)`
   OR b.LTP * b.`Volume (lacs)` >= 2 * a.LTP * a.`Volume (lacs)`;
