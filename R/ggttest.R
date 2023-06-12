#' @title
#' Student's t-test plot
#'
#' @description
#' Visualise one and/or two sample t-tests on vectors of data.
#'
#' @usage ggttest(t, colaccept="lightsteelblue1", colreject="grey84",
#' colstat="navyblue")
#'
#' @param t a list result of \code{\link{t.test}} of "htest" class
#' @param colaccept color the acceptance area of the test
#' @param colreject color for the rejection area of the test
#' @param colstat color for the test statistic vline
#'
#' @import ggplot2
#'
#' @rdname ggttest
#'
#' @export
#'
#' @examples
#'
#' t_test <- t.test(sleep$extra ~ sleep$group)
#' t_test
#' ggttest(t_test)
#'
#' t_test2 <- t.test(x = 1:10, y = c(7:20))
#' t_test2
#' ggttest(t_test2)
ggttest <- function(t,
                    colaccept = "lightsteelblue1",
                    colreject = "grey84",
                    colstat = "navyblue") {
  if (t$method == "One Sample t-test") {
    l1 <- length(eval(parse(text = t$data.name)))
    if (l1 > 30) {
      normt(t, colaccept, colreject, colstat)
    } else {
      studt(t, colaccept, colreject, colstat)
    }
  } else if (t$method == "Welch Two Sample t-test") {
    splitter <- if (isTRUE(grepl("by", t$data.name))) "by" else "and"
    datnames <- strsplit(t$data.name, splitter)
    len1 <- length(eval(parse(text = datnames[[1]][1])))
    len2 <- length(eval(parse(text = datnames[[1]][2])))
    if (len1 && len2 > 30) {
      normt(t, colaccept, colreject, colstat)
    } else {
      studt(t, colaccept, colreject, colstat)
    }
  } else { # both paired and t-test with equal variances follow t-distribution
    studt(t, colaccept, colreject, colstat)
  }
}

# choose based on
# l1<-length(eval(parse(text=t$data.name)))
# if (l1>30)-->
# sub function of normal distribution
normt <- function(t, colaccept, colreject, colstat) {
  # set points depending on test statistic
  # plot with normal distribution
  # set z(a/2)-score
  level <- 1 - as.numeric(attributes(t$conf.int))
  if (t$alternative == "two.sided") {
    ub <- abs(stats::qnorm(p = level / 2))
    lb <- -abs(stats::qnorm(p = level / 2))
  } else if (t$alternative == "greater") {
    ub <- abs(stats::qnorm(p = level))
  } else {
    lb <- -abs(stats::qnorm(p = level))
  }
  # chose area to plot based on the value of the statistic
  if (abs(t$statistic) > 4) {
    # test statistic follow N(0,1)
    # plot around 0
    points <- seq(
      from = -1 - abs(t$statistic),
      to = 1 + abs(t$statistic),
      length = 10000
    )
  } else {
    points <- seq(-4, 4, length = 10000)
  }
  # and limit points for plotting
  if (t$alternative == "two.sided") {
    limits <- points >= lb & points <= ub
  } else if (t$alternative == "greater") {
    limits <- points <= ub
  } else {
    limits <- points >= lb
  }
  # make data frames for ggplot
  if (t$alternative == "two.sided") {
    dfpoly1 <- data.frame(
      x = c(lb, points, ub),
      y = c(0, stats::dnorm(points), 0)
    )
    dfpoly2 <- rbind(c(lb, 0), dfpoly1[limits, ], c(ub, 0))
  } else if (t$alternative == "greater") {
    dfpoly1 <- data.frame(
      x = c(points, ub),
      y = c(stats::dnorm(points), 0)
    )
    dfpoly2 <- rbind(dfpoly1[limits, ], c(ub, 0))
  } else {
    dfpoly1 <- data.frame(x = c(lb, points), y = c(0, stats::dnorm(points)))
    dfpoly2 <- rbind(c(lb, 0), dfpoly1[limits, ])
  }
  # and plot
  normplot <- ggplot(data = data.frame(points), aes(points)) +
    stat_function(
      fun = stats::dnorm,
      n = 101,
      args = list(mean = 0, sd = 1),
      col = "white"
    ) +
    geom_polygon(data = dfpoly1, aes(x, y), fill = colreject) +
    geom_polygon(data = dfpoly2, aes(x, y), fill = colaccept) +
    labs(
      title = "Normal distribution Vs test statistic",
      subtitle = paste("Alternative hypothesis:", t$alternative),
      x = "Normal distribution",
      caption = paste("alpha=", level)
    ) +
    scale_y_continuous(breaks = NULL) +
    ylab("") +
    # add the statistics line
    geom_vline(aes(xintercept = data.frame(x = t$statistic)$x), col = colstat) +
    geom_text(
      data = data.frame(t$statistic),
      aes(
        x = data.frame(x = t$statistic)$x,
        y = 0.12,
        label = paste("Test statistic=", round(t$statistic, 4))
      ),
      colour = colstat,
      angle = 90, vjust = -0.4
    ) +
    theme_classic()
  if (t$alternative == "two.sided") {
    normplot +
      geom_vline(
        xintercept = data.frame(x = ub)$x,
        linetype = 2,
        alpha = 0
      ) +
      geom_vline(
        data = data.frame(x = lb),
        xintercept = data.frame(x = lb)$x,
        linetype = 2,
        alpha = 0
      ) +
      geom_text(
        data = data.frame(x = ub),
        aes(x = data.frame(x = ub)$x, y = -0.02),
        label = round(data.frame(x = ub)$x, 3), vjust = 0.3
      ) +
      geom_text(
        data = data.frame(x = lb),
        aes(x = data.frame(x = lb)$x, y = -0.02),
        label = round(data.frame(x = lb)$x, 3), vjust = 0.3
      )
  } else if (t$alternative == "greater") {
    normplot +
      geom_vline(aes(xintercept = ub), linetype = 2, alpha = 0) +
      geom_text(aes(x = ub, y = -0.02), label = round(ub, 3), vjust = 0.3)
  } else {
    normplot +
      geom_vline(
        data = data.frame(x = lb),
        xintercept = data.frame(x = lb)$x,
        linetype = 2,
        alpha = 0
      ) +
      geom_text(
        data = data.frame(x = lb),
        aes(x = data.frame(x = lb)$x, y = -0.02),
        label = round(data.frame(x = lb)$x, 3), vjust = 0.3
      )
  }
}

# else -->
studt <- function(t, colaccept, colreject, colstat) {
  # plot with student distribution
  level <- 1 - as.numeric(attributes(t$conf.int))
  df <- t$parameter
  if (t$alternative == "two.sided") {
    ub <- abs(stats::qt(p = level / 2, df = df))
    lb <- -abs(stats::qt(p = level / 2, df = df))
  } else if (t$alternative == "greater") {
    ub <- abs(stats::qt(p = level, df = df))
  } else {
    lb <- -abs(stats::qt(p = level, df = df))
  }
  # chose area to plot based on the value of the statistic
  if (abs(t$statistic) > 4) {
    # test statistic follow N(0,1)
    # plot around 0
    points <- seq(
      from = -1 - abs(t$statistic),
      to = 1 + abs(t$statistic),
      length = 10000
    )
  } else {
    points <- seq(-4, 4, length = 10000)
  }
  # and limit points for plotting
  if (t$alternative == "two.sided") {
    limits <- points >= lb & points <= ub
  } else if (t$alternative == "greater") {
    limits <- points <= ub
  } else {
    limits <- points >= lb
  }
  # make data frames for ggplot
  if (t$alternative == "two.sided") {
    dfpoly1 <- data.frame(
      x = c(lb, points, ub),
      y = c(0, stats::dt(points, df = df), 0)
    )
    dfpoly2 <- rbind(c(lb, 0), dfpoly1[limits, ], c(ub, 0))
  } else if (t$alternative == "greater") {
    dfpoly1 <- data.frame(
      x = c(points, ub),
      y = c(stats::dt(points, df = df), 0)
    )
    dfpoly2 <- rbind(dfpoly1[limits, ], c(ub, 0))
  } else {
    dfpoly1 <- data.frame(
      x = c(lb, points),
      y = c(0, stats::dt(points, df = df))
    )
    dfpoly2 <- rbind(c(lb, 0), dfpoly1[limits, ])
  }
  # and plot
  tplot <- ggplot(data = data.frame(points), aes(points)) +
    stat_function(
      fun = stats::dt,
      n = 101,
      args = list(df = df),
      col = "white"
    ) +
    geom_polygon(
      data = dfpoly1,
      aes(x, y),
      fill = colreject
    ) +
    geom_polygon(
      data = dfpoly2,
      aes(x, y),
      fill = colaccept
    ) +
    labs(
      title = "Student t distribution Vs test statistic",
      subtitle = paste("Alternative hypothesis:", t$alternative),
      x = paste("t distribution with", round(df), "degrees of freedom"),
      caption = paste("alpha=", level)
    ) +
    scale_y_continuous(breaks = NULL) +
    ylab("") +
    # add the statistics line
    geom_vline(aes(xintercept = data.frame(x = t$statistic)$x), col = colstat) +
    geom_text(
      data = data.frame(t$statistic),
      aes(
        x = data.frame(x = t$statistic)$x,
        y = 0.12,
        label = paste("Test statistic=", round(t$statistic, 4))
      ),
      colour = colstat,
      angle = 90,
      vjust = -0.4
    ) +
    theme_classic()
  if (t$alternative == "two.sided") {
    tplot +
      geom_vline(
        xintercept = data.frame(x = ub)$x,
        linetype = 2,
        alpha = 0
      ) +
      geom_vline(
        data = data.frame(x = lb),
        xintercept = data.frame(x = lb)$x,
        linetype = 2,
        alpha = 0
      ) +
      geom_text(
        data = data.frame(x = ub),
        aes(
          x = data.frame(x = ub)$x,
          y = -0.02
        ),
        label = round(data.frame(x = ub)$x, 3), vjust = 0.3
      ) +
      geom_text(
        data = data.frame(x = lb),
        aes(x = data.frame(x = lb)$x, y = -0.02),
        label = round(data.frame(x = lb)$x, 3), vjust = 0.3
      )
  } else if (t$alternative == "greater") {
    tplot +
      geom_vline(aes(xintercept = ub), linetype = 2, alpha = 0) +
      geom_text(aes(x = ub, y = -0.02), label = round(ub, 3), vjust = 0.3)
  } else {
    tplot +
      geom_vline(
        data = data.frame(x = lb),
        xintercept = data.frame(x = lb)$x,
        linetype = 2,
        alpha = 0
      ) +
      geom_text(
        data = data.frame(x = lb),
        aes(x = data.frame(x = lb)$x, y = -0.02),
        label = round(data.frame(x = lb)$x, 3), vjust = 0.3
      )
  }
}

utils::globalVariables(c("x", "y"))
