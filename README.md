# Priced Out

Housing affordability across ~50 countries, 1995–2026 — a Power BI report on how house
prices came apart from incomes, and where they didn't.

> **Status:** work in progress. Data source validated, report in design.

---

## The question

Since 2015, has housing become harder or easier to afford — and which countries moved
furthest in each direction?

Most coverage of this topic reports one country at a time, which makes every market look
uniquely broken. Put ~50 of them on the same axis and a different picture shows up: the
decoupling is widespread, but far from uniform — and a handful of countries went the other way.

## Data

[OECD — Analytical House Price Indicators](https://www.oecd.org/en/data/indicators/housing-prices.html):
real house price index, price-to-income ratio and price-to-rent ratio, quarterly and annual,
~50 countries including non-members. Last refreshed by the OECD in June 2026.

Pulled straight from the OECD SDMX API as CSV — no scraping, no manual download, no Python:

```
https://sdmx.oecd.org/public/rest/data/OECD.ECO.MPD,DSD_AN_HOUSE_PRICES@DF_HOUSE_PRICES,1.0/?startPeriod=1995&format=csvfilewithlabels
```

Power Query hits that URL directly through the Web connector, so the report refreshes itself
against the live OECD release.

## Method note — read before quoting a number

The OECD series are **indices with base 2015 = 100**. They measure how affordability
*changed over time*, not what a house *costs*.

This report can say *"34% less affordable than in 2015."*
It cannot say *"a house costs 8 years of income."*

Any absolute-level claim would need national price and income levels, which this dataset
does not carry. That limitation is stated on the report itself, not just here.

## Report structure

| Page | Question it answers |
|---|---|
| **The Decoupling** | Who moved, how far, and in which direction since 2015 |
| **Country Explorer** | How each country's affordability evolved across the full series |
| **Price vs. Rent** | Whether prices rose from housing scarcity or from housing as an asset |

## Stack

Power BI · Power Query (Web connector) · DAX · dimensional modeling

## License

MIT
