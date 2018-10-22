#' @title 
#' Plot for Pearson's Chi-squared Test for Count Data
#'  
#' @description
#' Visualise chi-squared contingency table tests and goodness-of-fit tests.
#' 
#' @usage ggchisqtest(t, colaccept="lightsteelblue1", colreject="gray84", 
#' colstat="navyblue", alpha=0.05)
#' 
#' @param t a list result of \code{\link{chisq.test}} of "htest" class
#' @param colaccept color the acceptance area of the test
#' @param colreject color for the rejection area of the test
#' @param colstat color for the test statistic vline
#' @param alpha default set to 0.05, choose confidence level for the plot as it is not stated in chisqtest
#' 
#' 
#' @import ggplot2
#' @importFrom rlang .data
#' 
#' 
#' @rdname ggchisqtest
#' 
#' @export
#' 
#' @examples 
#' ## Chi-squared test for given probabilities
#' 
#' x <- c(A = 20, B = 15, C = 25)
#' chisq_test <- chisq.test(x)
#' chisq_test
#' ggchisqtest(chisq_test)
#' 
#' 
#' x <- c(10, 86, 45, 38, 10)
#' p <- c(0.10, 0.40, 0.20, 0.20, 0.10)
#' chisq_test2 <- chisq.test(x, p = p)
#' chisq_test2
#' ggchisqtest(chisq_test2)
#' 
#' 
#' 
#' ## Pearson's Chi-squared test
#' 
#' library(MASS)
#' sex_smoke <- table(survey$Sex, survey$Smoke)
#' chisq_test3 <- chisq.test(sex_smoke)
#' chisq_test3
#' ggchisqtest(chisq_test3)
#' 

ggchisqtest<-function(t, colaccept="lightsteelblue1", colreject="gray84", colstat="navyblue", alpha=0.05) {
  
  df <- t$parameter #:=(s-1)(k-1)
  xstat <- t$statistic
  
  #confidence level, there is no way the user sets alpha in the test
  #so it is a parameter for the plot
  level <- 1 - alpha
  
  #make a list of points for the plot
  points <- seq(-0.25, 15, length = 10000)
  
  #set the upper bound
  ub <- stats::qchisq(p = level, df = df)
  
  #limit the points based on the upper bound
  limits <- points <= ub
  
  #make dataframes for ggplot
  dfpoly1 <- data.frame(x = c(points, ub), y = c(stats::dchisq(points, df), 0))
  dfpoly2 <- rbind(dfpoly1[limits,], c(ub, 0))
  
  plotchisq <- ggplot(data = data.frame(points), aes(points)) +
    
    stat_function(fun = stats::dchisq, n = 101, args = list(df = df), col = "white") +
    
    geom_polygon(data = dfpoly1, aes(dfpoly1$x, dfpoly1$y), fill = colreject) +
    
    geom_polygon(data = dfpoly2, aes(dfpoly2$x, dfpoly2$y), fill = colaccept) +
    
    labs(title = "Chi-squared distribution Vs test statistic",
         subtitle = paste("based on", t$method),
         x = paste("Chi-squared distributions with", df, "degrees of freedom"),
         caption = paste("alpha=", alpha))+
    
    scale_y_continuous(breaks=NULL) +
    
    ylab("") +
    #add the statistics line
    geom_vline(data = data.frame(x = xstat), aes(xintercept = data.frame(x = xstat)$x), colour = colstat, lwd = 1) +
    
    geom_text(data = data.frame(x = xstat), 
              aes(x = data.frame(x = xstat)$x, y = 0, 
                  label = paste("test statistic=", round(data.frame(x = xstat)$x, 3))),
              size = 4, 
              angle = 90, 
              vjust = -0.4, 
              hjust = 0, 
              colour = colstat) +
    
    geom_vline(aes(xintercept = ub), linetype = 2, alpha = 0) +
    
    geom_text(aes(x = ub, y = -0.02), label = round(ub,3), vjust = 0.3) +
    
    theme_classic()
  
  #plot it
  if (t$method=="Pearson's Chi-squared test"){
    plotchisq
  }
  else if (t$method=="Pearson's Chi-squared test with Yates' continuity correction"){
    plotchisq
  }
  else if (t$method=="Chi-squared test for given probabilities"){
    plotchisq
  }
  else {
    print("Chi-squared test is based on Monte-Carlo resampling and simulated p-value")
    
  }
}
