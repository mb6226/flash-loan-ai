"""
Aggregate prices from multiple DEX sources
"""

def aggregate_prices(*price_sources):
    # price_sources is a list of dicts {pair: price}
    # naive aggregator: take average
    result = {}
    for src in price_sources:
        for p, price in src.items():
            result.setdefault(p, []).append(price)

    return {p: sum(vals)/len(vals) for p, vals in result.items()}

if __name__ == '__main__':
    print('price aggregator loaded')
