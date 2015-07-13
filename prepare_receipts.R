
prepare_receipts <- function (data_receipts, today) {

data_receipts2 <- sqldf("
  SELECT
    customerId2,
    signalDate,
    count(*) as nProducts,
    sum(case when divisionId=4 then 1 else 0 end) as nProductsDivisionMO,
    sum(case when divisionId=5 then 1 else 0 end) as nProductsDivisionM,
    sum(case when divisionId=6 then 1 else 0 end) as nProductsDivisionWO,
    sum(case when divisionId=7 then 1 else 0 end) as nProductsDivisionW,
    sum(case when sourceId=1 then 1 else 0 end) as nProductsSourceF,
    sum(case when sourceId=2 then 1 else 0 end) as nProductsSourceD,
    sum(case when sourceId=3 then 1 else 0 end) as nProductsSourceS,
    sum(case when sourceId=4 then 1 else 0 end) as nProductsSourceO,
    sum(price) as sumPrice,
    sum(case when sourceId=1 then price else 0 end) as sumPriceSourceF,
    sum(case when sourceId=2 then price else 0 end) as sumPriceSourceD,
    sum(case when sourceId=3 then price else 0 end) as sumPriceSourceS,
    sum(case when sourceId=4 then price else 0 end) as sumPriceSourceO
  FROM data_receipts
  GROUP BY customerId2, signalDate")
                       
data_receipts2b <- data_receipts2 %>% group_by(customerId2) %>%
  mutate(rank = rank(signalDate, ties.method="first")) %>%
  arrange(signalDate)

data_receipts2c <- sqldf("
  SELECT
    s1.customerId2,
    s1.signalDate,
    s1.signalDate-s2.signalDate as intervalReceipts,
    s1.nProducts,
    s1.nProductsDivisionMO,
    s1.nProductsDivisionM,
    s1.nProductsDivisionWO,
    s1.nProductsDivisionW,
    s1.nProductsSourceF,
    s1.nProductsSourceD,
    s1.nProductsSourceS,
    s1.nProductsSourceO,
    s1.sumPrice,
    s1.sumPriceSourceF,
    s1.sumPriceSourceD,
    s1.sumPriceSourceS,
    s1.sumPriceSourceO
  FROM data_receipts2b s1
  LEFT JOIN data_receipts2b s2
  ON s2.rank = s1.rank - 1
    AND s2.customerId2 = s1.customerId2")

data_receipts3 <- fn$sqldf("
  SELECT
    customerId2,
    max(signalDate)-min(signalDate)+1 as periodReceipts,
    $today-max(signalDate) as periodReceiptsLastToday,
    avg(intervalReceipts) as avgIntervalReceipts,
    stdev(intervalReceipts) as stdIntervalReceipts,
    count(*) as nReceipts,
    sum(nProducts) as nProducts,
    nProductsDivisionMO/cast(nProducts as float) as ratProductsDivisionMO,
    nProductsDivisionM/cast(nProducts as float) as ratProductsDivisionM,
    nProductsDivisionWO/cast(nProducts as float) as ratProductsDivisionWO,
    nProductsDivisionW/cast(nProducts as float) as ratProductsDivisionW,
    nProductsSourceF/cast(nProducts as float) as ratProductsSourceF,
    nProductsSourceD/cast(nProducts as float) as ratProductsSourceD,
    nProductsSourceS/cast(nProducts as float) as ratProductsSourceS,
    nProductsSourceO/cast(nProducts as float) as ratProductsSourceO,
    sum(sumPrice) as sumPrice,
    sumPriceSourceF/sumPrice as ratPriceSourceF,
    sumPriceSourceD/sumPrice as ratPriceSourceD,
    sumPriceSourceS/sumPrice as ratPriceSourceS,
    sumPriceSourceO/sumPrice as ratPriceSourceO,
    avg(nProducts) as avgProducts,
    stdev(nProducts) as stdProducts,
    avg(sumPrice) as avgPrice,
    stdev(sumPrice) as stdPrice
  FROM data_receipts2c
  GROUP BY customerId2")

return(data_receipts3)

}
