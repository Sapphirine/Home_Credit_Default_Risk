import numpy
import pandas as pd

target = pd.read_csv('/Users/rachel/Desktop/2019 Spring/Advanced Big Data Analysis/my project/home-credit-default-risk-milestone3/final_model.csv')
application = pd.read_csv('/Users/rachel/Desktop/2019 Spring/Advanced Big Data Analysis/my project/home-credit-default-risk-milestone3/data/application_test.csv')


# Get user id
id = input('Please enter user id:')

# print target
print(target[target.SK_ID_CURR == id])
# condition1 = target['SK_ID_CURR']==id

# print('Target is:',target[condition1])
#
# # print personal information
# condition2 = application['SK_ID_CURR'] == id
# personal_information = application[conditon2]
# print('Personal Information is:')
# print('sex:',personal_information['CODE_GENDER'])
# print('Total Income:',personal_information['AMT_INCOME_TOTAL'])
#
#
# # Print family information
# print('number of children:',personal_information['CNT_CHILDREN'])
#
# # Print Property information
# print('if the clint has a car',personal_information['FLAG_OWN_CAR'])
# print('if the clint has a house',personal_information['FLAG_OWN_REALITY'])