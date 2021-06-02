## Google Analytics Customer Revenue Prediction

### 0. Legend

* [Project Overview](https://github.com/hnguyen1174/google-analytics-revenue#1-project-overview)
* [Project Structure](https://github.com/hnguyen1174/google-analytics-revenue#2-project-structure)
* [Clone the Repository](https://github.com/hnguyen1174/google-analytics-revenue#3-clone-the-repository)
* [The Data and EDA](https://github.com/hnguyen1174/google-analytics-revenue#4-the-data-and-eda)
* [Method](https://github.com/hnguyen1174/google-analytics-revenue#4-the-data-and-eda)
* [Random Forest Model Pipeline](https://github.com/hnguyen1174/google-analytics-revenue#6-random-forest-model-pipeline)
* [Light GBM Model Pipeline](https://github.com/hnguyen1174/google-analytics-revenue#7-light-gbm-model-pipeline)
* [Insights](https://github.com/hnguyen1174/google-analytics-revenue#7-light-gbm-model-pipeline)
* [Customer Revenue Prediction App](https://github.com/hnguyen1174/google-analytics-revenue#7-light-gbm-model-pipeline)
* [Project Artifacts](https://github.com/hnguyen1174/google-analytics-revenue#7-light-gbm-model-pipeline)
* [Next Steps](https://github.com/hnguyen1174/google-analytics-revenue#7-light-gbm-model-pipeline)

### 1. Project Overview

**Overview**

For many online businesses, the 20/80 rule of marketing holds true: 20% of the customer account for 80% of the revenue. Therefore, it is vital for businesses to come up with a marketing strategy to target these customers and attract similar ones. As the first step, businesses need to be able to identify these valuable customers and understand what are the common characteristics among them. Such characteristics might even become growth drivers for online sales.

**Objective**

The objective of this project is to build a model that can predict profitable customers from online sales data. I will analyze and use data from a Google Merchandise Store (GStore), which sells Google merchandise such as shirts or hats. The datasets are available on [Kaggle]( https://www.kaggle.com/c/ga-customer-revenue-prediction). 

The aim is twofold: first, from data analysis and modelling, I hope to extract insights into which customer and app features contribute most to revenue. Second, I hope to develop a model that can predict potential revenue from a customer. These predictions can then be used for targeted marketing.

The project also has a secondary objective. I will use this project to understand more about what kinds of data and features are available from Google Analytics.

**Success Criteria**

The target for prediction is the natural log of the per-user revenue:

<img src="media/target.png" alt="drawing" width="200"/>

The success criteria is to achieve a root mean square error (RMSE) less than 0.9 on a chosen test set.

### 2. Project Structure


```
├── README.md                              <- You are here
├── app
│   ├── templates/                         <- HTML files that is templated and changes based on a set of inputs
│   ├── Dockerfile_App                     <- Dockerfile for building image to run app 
│   ├── Dockerfile_Pipeline                <- Dockerfile for building image to run the random forest model pipeline  
│
├── config                                 <- Directory for configuration files 
│   ├── logging/                           <- Configuration of python loggers
│   ├── .aws                               <- Configurations for AWS and RDS
│   ├── flaskconfig.py                     <- Configurations for Flask API
│   ├── config.yml                         <- Configurations for developing and evaluating the model
│   ├── reproducibility_test_config.yml    <- Configurations for reproducibility tests
│
├── data                                   <- Folder that contains data used or generated. 
│
├── deliverables/                          <- Presentation Slide
│
├── r_scripts/                             <- Folder that contains data processing and exploratory data analysis outputs in R
│
├── models/                                <- Trained model objects, model predictions, feature importance and model evaluations
│
├── src/                                   <- Source code for the project 
│
├── test/                                  <- Files necessary for running unit tests and reproducibility tests
│   ├── reproducibility_true/              <- expected files for reproduciblity tests
│   ├── unit_test_true                     <- input and expect files for unit tests
│
├── app.py                                 <- Flask wrapper for running the model 
├── run.py                                 <- Simplifies the execution of one or more of the src scripts  
├── requirements.txt                       <- Python package dependencies 

```

### 3. Clone the Repository

In order to run the codes and the app, you first need to clone the repo to your local machine:

```
# To clone the repo
$ git clone https://github.com/hnguyen1174/google-analytics-revenue.git

# Go to the working directory
$ cd google-analytics-revenue
```

If you want to examine and run the R scripts, please go to `r_scripts` and open the R project `google-analytics-revenue.Rproj`.

### 4. The Data and EDA

### 5. Methods

### 6. Random Forest Model Pipeline

### 7. Light GBM Model Pipeline

### 8. Insights

### 9. Customer Revenue Prediction App

### 10. Project Artifacts

### 11. Next Steps
