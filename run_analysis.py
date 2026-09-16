"""Runs every SQL file in sql/ against the Olist CSVs using DuckDB and saves each result to outputs/.

Usage:  python run_analysis.py [path_to_csv_folder]   (defaults to ./data)
"""
import duckdb, glob, os, sys
import pandas as pd

DATA = sys.argv[1] if len(sys.argv) > 1 else 'data'
os.makedirs('outputs', exist_ok=True)
con = duckdb.connect('olist.duckdb')

for t in ['customers', 'order_items', 'order_payments', 'order_reviews', 'orders', 'products']:
    con.execute(f"CREATE OR REPLACE VIEW {t} AS SELECT * FROM read_csv_auto('{DATA}/olist_{t}_dataset.csv')")

translation = f'{DATA}/product_category_name_translation.csv'
if os.path.exists(translation):
    con.execute(f"CREATE OR REPLACE VIEW category_translation AS SELECT * FROM read_csv_auto('{translation}')")
else:
    print('Translation file not found, using built in names for the main categories')
    fallback = pd.read_csv('category_translation_fallback.csv')
    con.execute("CREATE OR REPLACE TABLE category_translation AS SELECT * FROM fallback")

for path in sorted(glob.glob('sql/*.sql')):
    sql = open(path).read()
    statements = [s for s in sql.split(';') if any(l.strip() and not l.strip().startswith('--') for l in s.splitlines())]
    result = None
    for s in statements:
        result = con.sql(s)
    name = os.path.basename(path)[:-4]
    if result is None:
        print(f'{name}: table built')
        continue
    df = result.df()
    df.to_csv(f'outputs/{name}.csv', index=False)
    print(f'\n== {name}\n{df.head(20).to_string()}')
