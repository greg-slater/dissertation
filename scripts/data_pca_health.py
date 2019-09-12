
from sklearn.preprocessing import StandardScaler
import numpy as np
from factor_analyzer import FactorAnalyzer
import pandas as pd
import factor_analyzer

health_raw = pd.read_csv('../shrinkage/lsoa_health_shrunk_scores_all_final.csv',
                         usecols = ['LSOA11CD', 'INDICATOR_GROUP_CODE', 'METHOD', 'rate'])

# take kn-10 shrinkage results health data
health_raw = health_raw[(health_raw['METHOD'] == 'KN-10')]
health_raw = health_raw[['LSOA11CD', 'INDICATOR_GROUP_CODE', 'rate']]

# pivot to wide table
health = health_raw.pivot(index = 'LSOA11CD', columns = 'INDICATOR_GROUP_CODE', values = 'rate')

health.columns.name = None
health = health.reset_index()

# check correct no. of LSOAs
print(len(health))
health.head()

# take just indicators and standardise
cols = ['DEM', 'DEP', 'CVDPP', 'OB'] 

vals = health[cols].values
ss = StandardScaler()
health_s = pd.DataFrame(ss.fit_transform(vals), columns = cols)
health_s.head()


# run factor analysis

fa = FactorAnalyzer()
fa.analyze(health_s, 4, method = 'principal', rotation = 'varimax')

fa.loadings.to_csv('pca_results_health.csv')

