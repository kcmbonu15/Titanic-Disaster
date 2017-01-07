# Titanic-Disaster
Machine Learning from disaster 

# Using R Machine learning
===================

Competition Description
---------------------
The sinking of the RMS Titanic is one of the most infamous shipwrecks in history.  On April 15, 1912, during her maiden voyage, the Titanic sank after colliding with an iceberg, killing 1502 out of 2224 passengers and crew. This sensational tragedy shocked the international community and led to better safety regulations for ships.

One of the reasons that the shipwreck led to such loss of life was that there were not enough lifeboats for the passengers and crew. Although there was some element of luck involved in surviving the sinking, some groups of people were more likely to survive than others, such as women, children, and the upper-class.

In this challenge, i was asked to complete the analysis of what sorts of people were likely to survive. In particular, we ask you to apply the tools of machine learning to predict which passengers survived the tragedy.

Classification Models used in Analysis:
---------------------------------------
I am going to use Decision tree algorithms for constructing decision trees by choosing a variable at each step
that best splits the set of items. It uses the Gini index which measures the total variances across the K classes, the gini index takes on a small values if all of them are close to zero or one. For the reason the Gini index is refered to as a measure of node purity - a small values indicates that a node contains predominanly observations from a single class
  
* Conclusion: 
------------------ 
In my conclusion we could see that Sex, Pclass, Parsh and fare a variables that are important as shown from the output results, i also use a k fold cross validation to prune the trees and made my final prediction on the test data sets to get an accuracy of 78%.This was my first Kaggle competition first submission.

