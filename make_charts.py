"""Builds the report charts from the CSVs in outputs/. Run run_analysis.py first."""
import os
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mt

os.makedirs('charts', exist_ok=True)
NAVY, ORANGE, GREY = '#1F3A5F', '#E07B39', '#B8C2CC'
plt.rcParams.update({'font.size': 10, 'axes.spines.top': False, 'axes.spines.right': False,
                     'axes.titleweight': 'bold', 'axes.titlesize': 12, 'figure.dpi': 130})
o = lambda n: pd.read_csv(f'outputs/{n}.csv')

def save(fig, name):
    fig.tight_layout()
    fig.savefig(f'charts/{name}.png', bbox_inches='tight')
    plt.close(fig)

# 1. Monthly revenue
m = o('01_monthly_trend'); m['order_month'] = pd.to_datetime(m['order_month'])
fig, ax = plt.subplots(figsize=(9, 4))
ax.plot(m['order_month'], m['revenue'] / 1e6, color=NAVY, marker='o', lw=2)
nov = m[m['order_month'] == '2017-11-01'].iloc[0]
ax.annotate('Black Friday\nNov 2017', (nov['order_month'], nov['revenue'] / 1e6), xytext=(-110, -25),
            textcoords='offset points', arrowprops=dict(arrowstyle='->', color=ORANGE), color=ORANGE)
ax.set_title('Revenue climbed through 2017, then levelled off at about 1M a month in 2018')
ax.set_ylabel('Revenue (BRL millions)')
save(fig, '01_monthly_revenue')

# 2. Top categories
c = o('02_top_categories').head(10).iloc[::-1]
fig, ax = plt.subplots(figsize=(9, 4.8))
ax.barh(c['category'], c['revenue'] / 1e6, color=NAVY)
for y, (r, s) in enumerate(zip(c['revenue'], c['avg_review'])):
    ax.text(r / 1e6 + 0.01, y, f'  review {s}', va='center', fontsize=8, color='#555')
ax.set_title('Top 10 categories by revenue')
ax.set_xlabel('Revenue (BRL millions)')
save(fig, '02_top_categories')

# 3. Repeat customers
r = o('03_repeat_customers')
fig, ax = plt.subplots(figsize=(7, 3.6))
ax.bar(r['bucket'], r['pct_customers'], color=[GREY, NAVY, NAVY])
for x, v in enumerate(r['pct_customers']):
    ax.text(x, v + 1.5, f'{v}%', ha='center')
ax.set_title('97% of customers never placed a second order')
ax.set_ylabel('% of customers'); ax.set_ylim(0, 110)
save(fig, '03_repeat_customers')

# 4. Late vs on time
d = o('04_delivery_vs_reviews').set_index('delivery').loc[['On time', 'Late']]
fig, axes = plt.subplots(1, 2, figsize=(9, 3.6))
axes[0].bar(d.index, d['avg_review'], color=[NAVY, ORANGE]); axes[0].set_ylim(0, 5)
axes[0].set_title('Average review score')
axes[1].bar(d.index, d['pct_bad_reviews'], color=[NAVY, ORANGE]); axes[1].set_ylim(0, 75)
axes[1].set_title('% of reviews that are 1 or 2 stars')
for ax, col, fmt in [(axes[0], 'avg_review', '{}'), (axes[1], 'pct_bad_reviews', '{}%')]:
    for x, v in enumerate(d[col]):
        ax.text(x, v * 1.03, fmt.format(v), ha='center')
fig.suptitle('Late deliveries wreck customer satisfaction', fontweight='bold')
save(fig, '04_late_vs_on_time')

# 5. Delivery speed
s = o('09_delivery_speed_vs_reviews')
s['label'] = s['delivery_time'].str[3:]
fig, ax = plt.subplots(figsize=(8, 3.8))
ax.plot(s['label'], s['avg_review'], color=NAVY, marker='o', lw=2)
for x, v in enumerate(s['avg_review']):
    ax.text(x, v + 0.12, v, ha='center')
ax.set_ylim(1.5, 5); ax.set_title('Reviews drop sharply once delivery passes three weeks')
ax.set_ylabel('Average review score')
save(fig, '05_delivery_speed')

# 6. States
st = o('05_delivery_by_state').sort_values('avg_delivery_days')
fig, ax = plt.subplots(figsize=(9, 4.5))
colors = [ORANGE if v >= 18 else NAVY for v in st['avg_delivery_days']]
ax.bar(st['customer_state'], st['avg_delivery_days'], color=colors)
ax.set_title('Average delivery time by state (states with 500+ orders)')
ax.set_ylabel('Days from purchase to delivery')
save(fig, '06_delivery_by_state')

# 7. RFM
f = o('06_rfm_segments').sort_values('pct_revenue')
fig, ax = plt.subplots(figsize=(9, 4))
y = range(len(f))
ax.barh([i + 0.2 for i in y], f['pct_customers'], height=0.4, color=GREY, label='% of customers')
ax.barh([i - 0.2 for i in y], f['pct_revenue'], height=0.4, color=NAVY, label='% of revenue')
ax.set_yticks(list(y)); ax.set_yticklabels(f['segment'])
ax.legend(frameon=False, loc='lower right'); ax.set_title('Customer segments (RFM)')
save(fig, '07_rfm_segments')

# 8. Heatmap
h = o('08_weekday_hour').pivot_table(index=['dow', 'weekday'], columns='hour', values='orders').reset_index(level=0, drop=True)
fig, ax = plt.subplots(figsize=(10, 3.4))
im = ax.imshow(h.values, aspect='auto', cmap='Blues')
ax.set_yticks(range(len(h))); ax.set_yticklabels(h.index)
ax.set_xticks(range(0, 24, 2)); ax.set_xticklabels(range(0, 24, 2))
ax.set_xlabel('Hour of day'); ax.set_title('When customers place orders')
ax.spines[:].set_visible(False)
fig.colorbar(im, ax=ax, label='Orders')
save(fig, '08_orders_heatmap')
print('charts saved:', sorted(os.listdir('charts')))
