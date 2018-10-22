#' @title 
#' Plot test of Equal or Given Proportions
#'  
#' @description
#' Visualise \code{\link{prop.test}} for testing the null that the proportions (probabilities of success) 
#' in several groups are the same, or that they equal certain given values.
#' 
#' @usage ggproptest(t, alpha=0.05,colaccept="lightsteelblue1", 
#' colreject="gray84", colstat="navyblue")
#' 
#' @param t a list result of \code{\link{prop.test}} of "htest" class
#' @param alpha alpha level for ploting distribution, when prop.test is used on more than 2 samples
#' @param colaccept color the acceptance area of the test
#' @param colreject color for the rejection area of the test
#' @param colstat color for the test statistic vline
#' 
#' @import ggplot2
#'
#' @rdname ggproptest
#' 
#' @export
#' 
#' @examples 
#' 
#' x  <- c(5, 8, 12)
#' y <- c(8, 9, 13)
#' pr_test <- prop.test(x, y)
#' pr_test
#' ggproptest(pr_test)
#' 

ggproptest <- function(t, alpha = 0.05, 
                       colaccept = "lightsteelblue1", colreject = "gray84", colstat = "navyblue"){
  df <- t$parameter 
  stat <- t$statistic
  
  textt <- t$method
  st <- strsplit(textt, split = "-")
  if (as.numeric(st[[1]][1]) <= 2) {
    level <- as.numeric(attributes(t$conf.int))
    #make a list of points for the plot
    points <- seq(-0.25, 8, length = 10000)
  } else {
    level = 1 - alpha
    #make a list of points for the plot
    points <- seq(-0.25, 20, length = 10000)
  }
  
  
  #set the upper bound
  ub <- stats::qchisq(p = level, df = df)
  #limit the points based on the upper bound
  limits <- points <= ub
  
  #make dataframes for ggplot
  dfpoly1 <- data.frame(x = c(points, ub), y = c(stats::dchisq(points, df),0))
  dfpoly2 <- rbind(dfpoly1[limits,], c(ub,0))
  
  plotpropt <- ggplot(data = data.frame(points), aes(points)) +
    stat_function(fun = stats::dchisq, args = list(df = df), col = "white") +
    geom_polygon(data = dfpoly1, aes(dfpoly1$x, dfpoly1$y), fill = colreject) +
    geom_polygon(data = dfpoly2, aes(dfpoly2$x, dfpoly2$y), fill = colaccept) +
    labs(title = "Chi-squared distribution Vs test statistic",
         subtitle = paste("based on", t$method),
         x = paste("Chi-squared distributions with", df, "degrees of freedom"),
         caption = paste("alpha=", 1 - level)) +
    scale_y_continuous(breaks = NULL) +
    ylab("") +
    #add the statistics line
    geom_vline(data = data.frame(x = stat), aes(xintercept = data.frame(x = stat)$x), colour = colstat, lwd = 1) +
    geom_text(data = data.frame(x = stat), aes(x = data.frame(x = stat)$x, y = 0, 
                                               label = paste("test statistic=", round(data.frame(x = stat)$x, 3))),
              size = 4, angle = 90, vjust = -0.4, hjust = 0, colour = colstat) +
    geom_vline(aes(xintercept = ub), linetype = 2, alpha = 0) +  
    geom_text(aes(x = ub, y = -0.02), label = round(ub,3), vjust = 0.3) +
    theme_classic()
  #plot it
  plotpropt
}
