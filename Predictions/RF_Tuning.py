from sklearn.ensemble import RandomForestRegressor
from collections import OrderedDict
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

RANDOM_STATE = 123
# read in the data as a Pandas data frame
wr_df = pd.read_csv('wrdata.csv',delimiter="," )


# Split data into dependent and independent variables
y = wr_df["fpts"]
x = wr_df.loc[:,wr_df.columns != "fpts"]



from collections import OrderedDict
ensemble_clfs = [
    ("RF_Regressor, max_feat='sqrt'",
        RandomForestRegressor(warm_start=True, oob_score=True,
                               max_features="sqrt",
                               random_state=RANDOM_STATE,criterion="mse")),
    ("RF_Regressor, max_feat='log2'",
        RandomForestRegressor(warm_start=True, max_features='log2',
                               oob_score=True,
                               random_state=RANDOM_STATE,criterion="mse")),
    ("RF_Regressor, max_feat=None",
        RandomForestRegressor(warm_start=True, max_features=None,
                               oob_score=True,
                            random_state=RANDOM_STATE,criterion="mse"))
]

# Map a classifier name to a list of (<n_estimators>, <error rate>) pairs.
error_rate = OrderedDict((label, []) for label, _ in ensemble_clfs)

# Range of `n_estimators` values to explore.
min_estimators = 50
max_estimators = 500

for label, clf in ensemble_clfs:
    for i in range(min_estimators, max_estimators + 1,50):
        clf.set_params(n_estimators=i)
        clf.fit(x, y)

        # Record the OOB error for each `n_estimators=i` setting.
        oob_error = clf.oob_score_
        error_rate[label].append((i, oob_error))
        print("%f completed") %i
# Generate the "OOB error rate" vs. "n_estimators" plot.
for label, clf_err in error_rate.items():
    xs, ys = zip(*clf_err)
    plt.plot(xs, ys, label=label)

plt.xlim(min_estimators, max_estimators)
plt.xlabel("n_estimators")
plt.ylabel("OOB error rate")
plt.legend(loc="upper right")
plt.show()

