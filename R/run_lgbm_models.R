#' Run LGBM Model
#'
#' @param train_matrix training matrix
#' @param train_matrix_ret training matrix of returned users
#' @param lgb_params_1 logistic regression params
#' @param lgb_params_2 regression params
#' @param test_matrix test matrix
#'
#' @return predictions and feature importance
#' @export
run_lgbm <- function(train_matrix, train_matrix_ret, test_matrix,
                     lgb_params_1, lgb_params_2) {
  
  lgb_preds_sum <- 0
  imp_total <- list()
  
  message('Training and Predictions')
  
  for (i in 1:10) {
    
    message(glue('Iteration {i}'))
    
    lgb_model_1 = lgb.train(
      train_matrix, 
      params = lgb_params_1, 
      nrounds = 1200, 
      bagging_seed = 2020 + i, 
      feature_fraction_seed = 2021 + i
    )
    
    lgb_preds_1 = predict(lgb_model_1, test_matrix)
    imp <- lgb.importance(lgb_model_1, percentage = TRUE)
    imp_total[[glue('model_1_iter_{i}')]] <- imp
    
    lgb_model2 = lgb.train(
      train_matrix_ret, 
      params = lgb_params_2, 
      nrounds = 368, 
      bagging_seed = 2020 + i, 
      feature_fraction_seed = 2021 + i
    )
    
    lgb_preds_2 = predict(lgb_model2, test_matrix)
    
    lgb_preds_sum = lgb_preds_sum + lgb_preds_1*lgb_preds_2
  }
  
  lgb_preds = lgb_preds_sum/10
  
  list(
    'imp_total' = imp_total,
    'lgb_preds' = lgb_preds
  )
}