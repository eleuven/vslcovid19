insheet using lifeexp.csv, clear
set type double

sum pcdeath_ic [fw=nboth]
g pcdeath_norway2 = .0033741 * pcdeath_ic / r(mean)

g d = survboth - survboth[_n+1]
replace d = survboth if d==.

g ll25 = .
g ll10 = .
qui  forv a=0/106 {
	sum age [aw=d] if age>=`a', det
	replace ll25 = r(p25) - `a' if age==`a'
	replace ll10 = r(p10) - `a' if age==`a'
}

g p60 = pcdeath_norway2 * .6
g ll60_mean = p60 * lifeexpboth
g ll60_25   = p60 * ll25
g ll60_10   = p60 * ll10

format ll* lifeexp* %10.1f
format nb p60 ll60* %12.0fc
format pcdeath_nor* %10.5f

expand 2
bys age : replace xage = "Total" if _n==1
replace lifeexpb = . if xage=="Total"
replace ll25 = . if xage=="Total"
replace ll10 = . if xage=="Total"

collapse (count) nboth (mean) pcdeath_norway2 (mean) lifeexpboth ll25 ll10 (sum) p60 ll60* [fw=nboth], by(xage)
list, sep(0) noob
