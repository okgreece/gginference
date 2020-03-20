#' @title 
#' Anova F test plot
#'  
#' @description
#' Visualise anova F-test to determine whether group means are equal
#' 
#' @usage ggaov(t, alpha=0.05, colaccept="lightsteelblue1", 
#' colreject="grey84", colstat="navyblue")
#' 
#' @param t an object of class aov
#' @param alpha alpha level for finding critical F value
#' @param colaccept color for the acceptance region of the test
#' @param colreject color for the area of rejection of the test
#' @param colstat color of the statistic of the test line
#' 
#' @import ggplot2
#' 
#' @rdname ggaov
#' 
#' @export
#' 
#' @examples
#' # 21-th day
#' chick21 <- ChickWeight[ChickWeight$Time == 21,]
#' chickaov <- aov(weight~Diet, data = chick21)
#' summary(chickaov)
#' 
#' ggaov(chickaov, colaccept = "grey89", colreject = "black")
#' 

ggaov <- function(t, alpha=0.05, colaccept="lightsteelblue1", colreject="grey84", colstat="navyblue"){
  #everything is stored in summary
  tt <- summary(t)
  
  #find out if it is one or two way anova
  #based of how many degrees of freedom there are
  if (length(tt[[1]]$Df) == 2) {
    Fstat <- tt[[1]][['F value']][1] 
    df1 <- tt[[1]]$Df[1] 
    df2 <- tt[[1]]$Df[2]
    
    #confidence level
    level <- 1 - alpha
    #make a list of points for the plot
    points <- seq(-0.5, 5, length = 10000)
    #set the upper bound
    ub  <-  stats::qf(p = level, df1 = df1, df2 = df2)
    #limit the points based on the upper bound
    limits <- points <= ub
    
    #make dataframes for ggplot
    dfpoly1 <- data.frame(x = c(points, ub), y = c(stats::df(points, df1, df2),0))
    dfpoly2 <- rbind(dfpoly1[limits,], c(ub,0))
    
    #plot it
    ggplot(data = data.frame(points),aes(points)) +
      stat_function(fun = stats::df, n = 100, args = list(df1 = df1, df2 = df2), col = "white") +
      geom_polygon(data = dfpoly1, aes(x, y), fill = colreject) +
      geom_polygon(data = dfpoly2, aes(x, y), fill = colaccept) +
      labs(title = "F distribution Vs test statistic",
           subtitle = "based on one way ANOVA",
           x = paste("F distribution with", df1, "&", df2, "degrees of freedom"),
           caption = paste("alpha =", 1 - level)) +
      scale_y_continuous(breaks = NULL) +
      ylab("") +
      #add the statistics line
      geom_vline(aes(xintercept = data.frame(x = Fstat)$x), col = colstat) +
      geom_text(data = data.frame(x = Fstat), aes(x = data.frame(x = Fstat)$x, y = 0.15,
                                                  label = paste("F value=",round(Fstat,4))),
                colour = colstat,angle = 90, vjust = -0.4) +
      #add critical F value
      geom_vline(aes(xintercept = ub), linetype = 2, alpha = 0) +  
      geom_text(aes(x = ub, y = -0.02), label = round(ub,3), vjust = 0.3) +
      theme_classic()
  }
  else if (length(tt[[1]]$Df) == 3) {
    for (i in 1:2) {
      #for factor A
      Fstat <- tt[[1]][['F value']][i] 
      df1 <- tt[[1]]$Df[i] 
      #within df
      df2 <- tt[[1]]$Df[3]  
      #confidence level
      level <- 1 - alpha
      #make a list of points for the plot
      points <- seq(-0.5, 5, length = 10000)
      #set the upper bound
      ub <- stats::qf(p = level, df1 = df1, df2 = df2)
      #limit the points based on the upper bound
      limits <- points <= ub
      
      #make dataframes for ggplot
      dfpoly1 <- data.frame(x = c(points, ub), y = c(stats::df(points, df1, df2),0))
      dfpoly2 <- rbind(dfpoly1[limits,], c(ub,0))
      
      #plot it
      ggplot(data = data.frame(points),aes(points)) +
        stat_function(fun = stats::df, n = 100, args = list(df1 = df1, df2 = df2), col = "white") +
        geom_polygon(data = dfpoly1, aes(x, y), fill = colreject) +
        geom_polygon(data = dfpoly2, aes(x, y), fill = colaccept) +
        labs(title = "F distribution Vs test statistic",
             subtitle = "based on two way ANOVA",
             x = paste("F distribution with", df1, "&", df2, "degrees of freedom"),
             caption = paste("alpha =", 1 - level)) +
        scale_y_continuous(breaks = NULL) +
        ylab("") +
        #add the statistics line
        geom_vline(aes(xintercept = data.frame(x = Fstat)$x), col = colstat) +
        geom_text(data = data.frame(x = Fstat), aes(x = data.frame(x = Fstat)$x, y = 0.15,
                                                    label = paste("F value=",round(Fstat,4))),
                  colour = colstat,angle = 90, vjust = -0.4) +
        #add critical F value
        geom_vline(aes(xintercept = ub), linetype = 2, alpha = 0) +  
        geom_text(aes(x = ub, y = -0.02), label = round(ub,3), vjust = 0.3) +
        theme_classic()
      
    }
  }
}
