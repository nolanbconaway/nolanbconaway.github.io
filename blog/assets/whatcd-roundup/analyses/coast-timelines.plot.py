import sqlite3
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from scipy.signal import savgol_filter

import seaborn as sns
sns.set_style("whitegrid")

flatui = ["#34495e", "#e74c3c", "#95a5a6"]
sns.set_palette(flatui)

# get the data...
con = sqlite3.connect('data.db')
tags = pd.read_sql_query('SELECT * from tags;', con)
torrents = pd.read_sql_query('SELECT * from torrents;', con)
con.close()

# A list of tags associated with each region. These were handpicked but I think they are fair!
coast_tags = {
    'East Coast': ['new.york', 'east.coast','east.coast.rap'],
    'West Coast': ['bay.area', 'los.angeles', 'west.coast', 'california'],
    'Dirty South': ['dirty.south', 'southern', 'southern.rap','southern.hip.hop', 'new.orleans', 'houston', 'memphis', 'atlanta'],
    }

yearly_counts = pd.DataFrame(data = None, columns = ['Year'] + list(coast_tags.keys()))
for year in range(1985, 2017):
    ids = torrents.id.loc[torrents.groupYear==year]
    yeartags = tags.loc[tags.id.isin(ids)]
    
    # create row for dataframe
    row = dict(Year = year)
    for k,v in coast_tags.items():
        releases = yeartags.loc[yeartags.tag.isin(v), 'id']
        row[k] = pd.unique(releases).shape[0]

    # add row
    yearly_counts = yearly_counts.append(row, ignore_index = True)


fh = plt.figure(figsize=(8,3))
for k in coast_tags.keys():

	y = savgol_filter(yearly_counts[k],9,4)
	plt.plot(yearly_counts.Year,y,'-',label=k)

plt.ylabel('Hip Hop Releases')
plt.gca().xaxis.grid(False)
plt.xlim([1984.5,2016.5])

leg = plt.legend(loc='upper left', frameon = True)


plt.tight_layout()
fh.savefig('../coast-timelines.png', bbox_inches = 'tight')



