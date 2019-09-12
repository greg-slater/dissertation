
from sklearn.preprocessing import StandardScaler
from factor_analyzer import FactorAnalyzer
import pandas as pd
import factor_analyzer

air = pd.read_csv('../initial/data_pollution/lon_lsoa_pollution_all.csv')
air.head()

# take just indicators and standardise
vals = air.iloc[:,1:].values

ss = StandardScaler()
air_s = pd.DataFrame(ss.fit_transform(vals), columns = air.columns[1:])

air_s.describe()

# run factor analysis

fa = FactorAnalyzer()
fa.analyze(air_s, 4, method = 'principal', rotation = None)

fa.loadings.to_csv('pca_results_air_.csv')

