# Bag of Words - Context Prediction (Random Forest Model)

### Model has been trained using ensemble learning based on building a forest of trees. Basis click-logs, have identified top clicked product for each of search term and using its category as the keywords' category, which forms the training input for machine learning. The data has been split as 75% training, 25% validation set. The model has been built on python scikit learn module. Below are the parameters and accuracy of the model as it stands now, after a little bit of tuning.

## Evaluation
Classification Accuracy 
* Test set = 81%   (out of sample error = 19%)
* Training set = 90% (in sample error = 10%)
      81% accuracy in test set in terms of no. of queries classified accurately, should convert to 90% + in terms of search volume (impressions). As the misclassifed searches are usually due to low volume in training set. 

## Parameters of Model
* Model = Random Forest Ensemble Learning
* No. of Features used =5K
* No. of trees built = 15
* Tokenizer = Tf-idf
* Training set size = 90K
* Test set size = 30K
​* entropy measure = gini index

## Tech​
Trained using python scikit learning with parallelism = 4 (one thread per core) and training time of ~ 6mins with model output being 1.1GB in size. Time to classify 30K searches = ~6s taking the throughput to 5K queries per second.


