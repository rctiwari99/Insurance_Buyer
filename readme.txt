The dataset contains information about all the passengers abord the titanic.

1. Survived column 0 - Did not survive, 1 - Survived
2. pclass - ticket class - 1 = 1st, 2 = 2nd, 3 = 3rd
A proxy for socio-economic status (SES)
1st = Upper
2nd = Middle
3rd = Lower
3. sex
4. age in years
5. sibsp - # of siblings / spouses aboard the Titanic
The dataset defines family relations in this way...
Sibling = brother, sister, stepbrother, stepsister
Spouse = husband, wife (mistresses and fiancés were ignored)

6. parch - # of parents / children aboard the Titanic
The dataset defines family relations in this way...
Parent = mother, father
Child = daughter, son, stepdaughter, stepson
Some children travelled only with a nanny, therefore parch=0 for them.

7. ticket - ticket number
8. fare - passenger fare
9. cabin - cabin number
10. embarked - port of embarkation, C = Cherbourg, Q = Queenstown, S = Southampton

The aim is to predict which passenger will survive and which variables contribute for a passenger to survive.

The dataset has missing values to passenger age variable which is taken care by imputation based on feature engineering.

The logistic regression model yield an AUC of 89%.
