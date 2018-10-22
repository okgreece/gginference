#' @title 
#' F test plot
#'  
#' @description
#' Visualise F test to compare two variances
#' 
#' @usage ggvartest(t, colaccept = "lightsteelblue1", 
#' colreject = "gray84", colstat = "navyblue")
#' 
#' @param t a list result of \code{\link{var.test}} of "htest" class
#' @param colaccept color the acceptance area of the test, see  \code{\link{colors}}
#' @param colreject color for the rejection area of the test
#' @param colstat color for the test statistic vline
#' 
#' 
#' @import ggplot2
#' @importFrom rlang .data
#' 
#' @rdname ggvartest
#' 
#' @export
#' 
#' @examples 
#' 
#' x <- rnorm(50, mean = 0, sd = 2)
#' y <- rnorm(30, mean = 1, sd = 1)
#' var_test <- var.test(x, y)
#' var_test
#' ggvartest(var_test)
#' 

ggvartest <- function(t, colaccept = "lightsteelblue1", 
                      colreject = "gray84", colstat = "navyblue"){
  
  #1-alpha,is needed for F distribution
  level <- as.numeric(attributes(t$conf.int))
  
  #degrees of freedom for variance test
  if (t$alternative == "two.sided") {
    if (t$statistic > 1) {
      df1 <- t$parameter[1]
      df2 <- t$parameter[2]
      t$statistic <- t$statistic
    }
    else {
      df1 <- t$parameter[2]
      df2 <- t$parameter[1]
      t$statistic <- 1/t$statistic
    }
  } else if (t$alternative == "greater") {
    df1 <- t$parameter[1]
    df2 <- t$parameter[2]
  } else {
    df1 <- t$parameter[2]
    df2 <- t$parameter[1]
  }
  
  #sequence of points for F-distribution
  points <- seq(-0.25, 7, length = 10000)
  
  #upper bound for all alternatives
  ub <- stats::qf(p = level, df1 = df1, df2 = df2)
  limits <- points <= ub
  
  #make dataframes for ggplot
  dfpoly1 <- data.frame(x = c(points, ub), y = c(stats::df(points, df1, df2), 0))
  dfpoly2 <- rbind(dfpoly1[limits,], c(ub,0))
  
  #plot it
  ggplot(data = data.frame(points), aes(points)) +
    stat_function(
      fun = stats::df, 
      n = 101, 
      args = list(df1 = df1, df2 = df2), 
      colour = "white") +
    
    geom_polygon(
      data = dfpoly1,
      aes(dfpoly1$x, dfpoly1$y), 
      fill = colreject) +
    
    geom_polygon(
      data = dfpoly2, 
      aes(dfpoly2$x, dfpoly2$y), 
      fill = colaccept) +
    
    labs(
      title = "F distribution Vs test statistic",
      subtitle = paste("Alternative hypothesis:", t$alternative),
      x = paste("F distributions with", df1, "&", df2, "degrees of freedom"),
      caption = paste("alpha=", 1 - level)) +
    
    scale_y_continuous(breaks = NULL) +
    
    ylab("") +
    
    #add the statistics line
    geom_vline(
      data = data.frame(x = t$statistic),
      aes(xintercept = data.frame(x = t$statistic)$x),
      colour = colstat, lwd = 1) +
    
    geom_text(
      data = data.frame(x = t$statistic), 
      aes(x = data.frame(x = t$statistic)$x,
          y = 0, 
          label = paste("test statistic=", round(data.frame(x = t$statistic)$x, 3))),
      size = 4, angle = 90, vjust = -0.4, hjust = 0, colour = colstat) +
    
    theme_classic() +
    
    #add the F-score
    geom_vline(aes(xintercept = ub), linetype = 2, alpha = 0) +  
    
    geom_text(aes(x = ub, y = -0.025), label = round(ub,3), vjust = 0.3)
  
}
