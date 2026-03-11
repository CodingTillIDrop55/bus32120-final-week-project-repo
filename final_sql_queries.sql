

-- Query 1: Join stock returns with VIX by date
SELECT
    r.date,
    r.ticker,
    r.ret,
    f.vix
FROM returns r
JOIN factors f
    ON r.date = f.date
ORDER BY r.date, r.ticker;



-- Query 2: Average return by ticker when VIX is high
SELECT
    r.ticker,
    AVG(r.ret) AS avg_ret_high_vix,
    COUNT(*) AS n_days
FROM returns r
JOIN factors f
    ON r.date = f.date
WHERE f.vix >= 25
GROUP BY r.ticker
ORDER BY avg_ret_high_vix DESC;



-- Query 3: Average daily return and average VIX by ticker
SELECT
    r.ticker,
    AVG(r.ret) AS avg_daily_return,
    AVG(f.vix) AS avg_vix_on_observed_days,
    COUNT(*) AS n_obs
FROM returns r
JOIN factors f
    ON r.date = f.date
GROUP BY r.ticker
ORDER BY avg_daily_return DESC;



-- Query 4: Average return and volatility proxy by ticker
SELECT
    ticker,
    AVG(ret) AS avg_daily_return,
    ROUND(SQRT(AVG(ret * ret) - AVG(ret) * AVG(ret)), 6) AS daily_volatility_proxy,
    COUNT(*) AS n_obs
FROM returns
GROUP BY ticker
ORDER BY daily_volatility_proxy DESC;



-- Query 5: Best and worst daily return by ticker
SELECT
    ticker,
    MIN(ret) AS worst_day,
    MAX(ret) AS best_day
FROM returns
GROUP BY ticker
ORDER BY worst_day ASC;



-- Query 6: 21-day rolling average return by ticker
SELECT
    date,
    ticker,
    ret,
    AVG(ret) OVER (
        PARTITION BY ticker
        ORDER BY date
        ROWS BETWEEN 20 PRECEDING AND CURRENT ROW
    ) AS rolling_21d_avg_ret
FROM returns
ORDER BY ticker, date;



-- Query 7: 21-day rolling volatility proxy by ticker
SELECT
    date,
    ticker,
    ret,
    ROUND(
        SQRT(
            AVG(ret * ret) OVER (
                PARTITION BY ticker
                ORDER BY date
                ROWS BETWEEN 20 PRECEDING AND CURRENT ROW
            ) -
            (
                AVG(ret) OVER (
                    PARTITION BY ticker
                    ORDER BY date
                    ROWS BETWEEN 20 PRECEDING AND CURRENT ROW
                )
            ) *
            (
                AVG(ret) OVER (
                    PARTITION BY ticker
                    ORDER BY date
                    ROWS BETWEEN 20 PRECEDING AND CURRENT ROW
                )
            )
        ),
        6
    ) AS rolling_21d_vol
FROM returns
ORDER BY ticker, date;



-- Query 8: Days where a stock's return is above its own historical average
SELECT
    r.date,
    r.ticker,
    r.ret
FROM returns r
WHERE r.ret > (
    SELECT AVG(r2.ret)
    FROM returns r2
    WHERE r2.ticker = r.ticker
)
ORDER BY r.ticker, r.date;



-- Query 9: Stock returns below the portfolio's average daily return
SELECT
    r.date,
    r.ticker,
    r.ret
FROM returns r
WHERE r.ret < (
    SELECT AVG(p.portfolio_ret)
    FROM portfolio_returns p
)
ORDER BY r.ret ASC;



-- Query 10: Portfolio returns on days when VIX is above its own average
SELECT
    p.date,
    p.portfolio_ret,
    f.vix
FROM portfolio_returns p
JOIN factors f
    ON p.date = f.date
WHERE f.vix > (
    SELECT AVG(vix)
    FROM factors
)
ORDER BY f.vix DESC, p.date;

