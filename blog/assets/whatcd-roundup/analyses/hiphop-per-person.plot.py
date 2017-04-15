import sqlite3
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

import seaborn as sns
sns.set_style("whitegrid")
sns.set_palette("GnBu_d")

# start connection to sqlite data, grab data, then close connection
con = sqlite3.connect('data.db')
tags = pd.read_sql_query('SELECT * from tags;', con)
cities = pd.read_sql_query('SELECT * from cities;', con)
con.close()

# first, get the overall frequency of each tag
tagfrequency = tags.tag.value_counts()

# make tag frequency a dataframe, clean it up
tagfrequency = tagfrequency.to_frame(name = 'frequency')
tagfrequency['city'] = tagfrequency.index
tagfrequency.reset_index(inplace = True, drop = True)

# second, merge the tag frequency with each city in the database
merged = pd.merge(cities, tagfrequency, on = 'city')
merged['ratio'] = merged.frequency / (merged.population / 100000.0) 
merged['logpop'] = np.log(merged.population + 1)


fh, ax = plt.subplots(1, 2, figsize=(8, 3))

h = ax[0]
merged = merged.sort_values(by = 'frequency', ascending = False)
h.bar(range(10), merged.iloc[0:10].frequency, 0.9)
h.set_xlim([-0.6,9.6])
h.set_xticks([])
for i in range(10):
    h.text(i+0.3, 0, merged.iloc[i].city, rotation = 35, va = 'top', ha = 'right')
h.set_title('Total Hip Hop Releases')


h = ax[1]
merged = merged.sort_values(by = 'ratio', ascending = False)
h.bar(range(10), merged.iloc[0:10].ratio, 0.9)
h.set_xlim([-0.6,9.6])
h.set_xticks([])
for i in range(10):
    h.text(i+0.3, 0, merged.iloc[i].city, rotation = 35, va = 'top', ha = 'right')
h.set_title('Hip Hop Releases Per 100k People')


plt.tight_layout()



fh.savefig('../tags-per-person.png', bbox_inches = 'tight')