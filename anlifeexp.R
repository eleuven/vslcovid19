library(data.table)
library(Hmisc) # wtd.quantile
weighted.sum = function(x, w) round(sum(x * w))

dt = fread("lifeexp.csv")

mkor = wtd.mean(dt$pcdeath_korea, dt$nboth)
dt[, pcdeath_nor :=  .0036345 * pcdeath_korea / mkor]
dt[, p60 := pcdeath_nor * .6]
dt[, d := survboth - survboth[.I + 1]]
dt[.N, d := survboth]
qt = function(a, q) with(dt[age >= a], wtd.quantile(age, d, q) - a)
dt[, ll10 := qt(age, .10), by = 1:nrow(dt)]
dt[, ll25 := qt(age, .25), by = 1:nrow(dt)]
setnames(dt, "lifeexpboth", "llmean")
dt[, p60llmean := p60 * llmean]
dt[, p60ll25   := p60 * ll25]
dt[, p60ll10   := p60 * ll10]

dt = rbind(dt, copy(dt)[, xage := "Total"])

v1 = c("pcdeath_nor", "llmean", "ll25", "ll10")
v2 = c("p60", "p60llmean", "p60ll25", "p60ll10")

results = cbind(
  dt[, sum(nboth), by = xage],
  dt[, lapply(.SD, weighted.mean, nboth), by = xage, .SDcols = v1][, -1],
  dt[, lapply(.SD, weighted.sum , nboth), by = xage, .SDcols = v2][, -1]
)

results
