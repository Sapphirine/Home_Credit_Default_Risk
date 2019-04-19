import os
import config
# import numpy
import pandas as pd



GBM = pd.read_csv(os.path.join(config.DATA_DIRECTORY, 'feature_importancelight_GBM.csv'), nrows=num_rows)
rf = pd.read_csv(os.path.join(config.DATA_DIRECTORY, 'rf_baseline.csv'), nrows=num_rows)
logreg = pd.read_csv(os.path.join(config.DATA_DIRECTORY, 'logreg_baseline.csv'), nrows=num_rows)

df = pd.merge(GBM, rf, on='SK_ID_CURR', how='left')
df = pd.merge(df,logreg,on="SK_ID_CURR",how= 'left')

list = [i/10.0 for i in range(11)]

for i in list :
    for j in list :
        k = 1 - i - j
