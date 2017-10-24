from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_val_score, cross_validate
from sklearn import metrics as met
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

randomseed = 123
# read in the data as a Pandas data frame
wr_df = pd.read_csv('wrdata.csv',delimiter="," )

# Split data into dependent and independent variables
y = wr_df["fpts"]
x = wr_df.iloc[:,7:13]

x = wr_df.loc[:,wr_df.columns != "fpts"]


# Split data into train and test sets
x_train, x_test, y_train, y_test = train_test_split(x,y
                                                    ,test_size=.30
                                                    ,random_state=randomseed)


# Create random forest model
wr_rf = RandomForestRegressor(n_estimators=15,
                              max_depth=4,
                              min_samples_split=.05,
                              random_state=randomseed,
                              oob_score=True,
                              criterion="mse")

#Cross Validated model
cv = cross_validate(wr_rf,x_train, y_train,
                    cv = 10, scoring=('r2','neg_mean_squared_error'))

#print("Accuracy: %0.2f (+/- %0.2f)" % (cv.mean(), cv.std() * 2))
print(cv['train_r2'].mean())
print(cv['test_r2'].mean())
print(cv['train_neg_mean_squared_error'].mean())
print(cv['test_neg_mean_squared_error'].mean())
#print("R2: %f") % cv['train_r2'].mean

wr_rf.fit(x_train,y_train)
preds = wr_rf.predict(x_test)
print("MAE: %f") % met.mean_absolute_error(preds,y_test)
print("MSE: %f") % met.mean_squared_error(preds,y_test)

# plt.scatter(y_test,preds,marker=',',s=1)
# plt.xlim(0,50)
# plt.ylim(0,50)
# plt.xlabel("Actual")
# plt.ylabel("Predicted")

plt.hist(preds, bins = 30)
plt.show()

for j in range(0,len(x_train.columns)):
    if wr_rf.feature_importances_[j] > 0.001:
        print("%s has importance %f") % (str(x_train.columns.values[j]), wr_rf.feature_importances_[j])




# Fit model to training data and print results
wr_rf.fit(x_train,y_train)
print(wr_rf.score(x_test,y_test))
print(wr_rf.oob_score_)

preds = wr_rf.predict(x_test)


# Plotting our predictions
plt.scatter(y_test,preds)
plt.xlim(5,45)
plt.ylim(5,45)
plt.xlabel("Actual")
plt.ylabel("Predicted")
plt.show()




# scores = list()
# for i in range(20, 50):
#     wr_rf = RandomForestRegressor(n_estimators=i
#                               #,max_depth=6
#                               #,min_samples_split=.05
#                               ,random_state=randomseed
#                               ,oob_score=True)
#     cv = cross_val_score(wr_rf,x, y)
#     scores.append(cv.mean())
# plt.plot(scores)
# plt.show()
