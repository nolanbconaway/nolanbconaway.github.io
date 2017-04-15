import sqlite3
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

import seaborn as sns
sns.set_style("whitegrid")
sns.set_palette("GnBu_d")

con = sqlite3.connect('data.db')
torrents = pd.read_sql_query("SELECT * from torrents", con)
tags = pd.read_sql_query("SELECT * from tags", con)
con.close()

# only consider releases containing 'new' material
torrents = torrents[torrents.releaseType.isin(['album','mixtape'])]
torrents = torrents[~torrents.artist.isin(['various artists'])]

# define a function to plot bar graphs
def plotbars(h, data, topn = 10):
    xticks = np.arange(topn)
    vals = data.sort_values(ascending = False)[:topn]
    
    # plotting
    h.bar(xticks-0.5, vals, width = 0.9, linewidth = 1)
    h.set_xticks([])
    h.axis([-1.25, topn-0.75, 0, max(vals) + max(vals)*0.05])
    for j in range(topn):  
        h.text(xticks[j], 0, vals.index[j].title() + ' ', 
            ha = 'right', va = 'top', rotation = 35, fontsize = 12)

# group by artist
grouping = torrents.groupby('artist')

# count overall number of releases
counts = grouping.size()

# get years of activity
years = grouping.groupYear.agg(['min', 'max'])
ranges = years['max'] - years['min'] + 1


# combine into dataframe
df = pd.DataFrame(dict(
	counts = counts,
	years = ranges,
	peryear = counts / ranges,
	))


# plotting
f, ax = plt.subplots(1, 2, figsize=(8, 3))
plotbars(ax[0], df.counts)
ax[0].set_title('Cumulative Releases', fontsize = 14)

plotbars(ax[1], df.peryear)
ax[1].set_title('Releases Per Year', fontsize = 14)


plt.tight_layout()
plt.savefig('../prolific-artists.png', bbox_inches = 'tight')



df = df.loc[df.years > 2]
print df.sort_values(by = 'peryear', ascending = False)


f, ax = plt.subplots(1, 1, figsize=(5, 3))
plotbars(ax, df.peryear)
ax.set_title('Artists with 3+ Years of Releases', fontsize = 14)
ax.set_ylabel('Releases Per Year', fontsize = 12)
plt.savefig('../prolific-artists-3plus.png', bbox_inches = 'tight')
