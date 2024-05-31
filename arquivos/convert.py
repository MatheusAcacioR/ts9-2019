from scipy.io import loadmat 
import pandas as pd
data = loadmat("Testing_dataset6(24_days_subset).mat")
data  = {k:v for k, v in data.items() if k[0] != '_'}
df = pd.DataFrame({k: pd.Series(v[0]) for k, v in data.items()})  
df.to_csv("Testing_dataset6(24_days_subset).csv")