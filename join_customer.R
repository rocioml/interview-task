
join_customer <- function (data_customer_prep, data_session_prep, data_receipts_prep, data_returns_prep) {
  
customer<-sqldf("
  SELECT
    c.customerId2,
    churn,
    female,
    age,
    periodCreatedToday,
    premierNever,
    premier1,
    premier2,
    premier3,
    premier4,
    premier5,
    premier6,
    premierActive,
    premierPast,
    case when shippingCountry='UK' then 1 else 0 end as uk,
    case when shippingCountry=siteCountryPurchased then 1 else 0 end as equalCountry,
    case when periodActivity is null then 0 else periodActivity end as periodActivity,
    case when periodActivityLastToday is null then 5*365 else periodActivityLastToday end as periodActivityLastToday,
    case when avgInterval is null then periodCreatedToday else avgInterval end as avgInterval,
    case when stdInterval is null then periodCreatedToday else stdInterval end as stdInterval,
    case when nSessions is null then 0 else nSessions end as nSessions,
    case when ratSessionWeekend is null then 0 else ratSessionWeekend end as ratSessionWeekend,
    case when nDevices is null then 0 else nDevices end as nDevices,
    case when ratPhone is null then 0 else ratPhone end as ratPhone,
    case when ratTablet is null then 0 else ratTablet end as ratTablet,
    case when ratComputer is null then 0 else ratComputer end as ratComputer,
    case when avgPageViewCount is null then 0 else avgPageViewCount end as avgPageViewCount,
    case when avgNonPageViewEventsCount is null then 0 else avgNonPageViewEventsCount end as avgNonPageViewEventsCount,
    case when avgProductViewCount is null then 0 else avgProductViewCount end as avgProductViewCount,
    case when avgProductsAddedToBagCount is null then 0 else avgProductsAddedToBagCount end as avgProductsAddedToBagCount,
    case when avgProductsSavedForLaterCount is null then 0 else avgProductsSavedForLaterCount end as avgProductsSavedForLaterCount,
    case when avgProductsPurchasedTotalCount is null then 0 else avgProductsPurchasedTotalCount end as avgProductsPurchasedTotalCount,
    case when avgPageViewCount2 is null then 0 else avgPageViewCount2 end as avgPageViewCount2,
    case when avgNonPageViewEventsCount2 is null then 0 else avgNonPageViewEventsCount2 end as avgNonPageViewEventsCount2,
    case when avgProductViewCount2 is null then 0 else avgProductViewCount2 end as avgProductViewCount2,
    case when avgProductsAddedToBagCount2 is null then 0 else avgProductsAddedToBagCount2 end as avgProductsAddedToBagCount2,
    case when avgProductsSavedForLaterCount2 is null then 0 else avgProductsSavedForLaterCount2 end as avgProductsSavedForLaterCount2,
    case when avgProductsPurchasedTotalCount2 is null then 0 else avgProductsPurchasedTotalCount2 end as avgProductsPurchasedTotalCount2,
    case when periodReturnsLastToday is null then 5*365 else periodReturnsLastToday end as periodReturnsLastToday,
    periodReturnsNotCancelLastToday,
    case when nReturnActionCancel is null then 0 else nReturnActionCancel end as nReturnActionCancel,
    case when nReturnActionRefund is null then 0 else nReturnActionRefund end as nReturnActionRefund,
    case when nReturnActionReplacement is null then 0 else nReturnActionReplacement end as nReturnActionReplacement,
    case when nReturnReasonGrade1 is null then 0 else nReturnReasonGrade1 end as nReturnReasonGrade1,
    case when nReturnReasonGrade2 is null then 0 else nReturnReasonGrade2 end as nReturnReasonGrade2,
    case when nReturnReasonGrade3 is null then 0 else nReturnReasonGrade3 end as nReturnReasonGrade3,
    periodReceipts,
    periodReceiptsLastToday,
    case when avgIntervalReceipts is null then 5*365 else avgIntervalReceipts end as avgIntervalReceipts,
    stdIntervalReceipts,
    nReceipts,
    nProducts,
    ratProductsDivisionMO,
    ratProductsDivisionM,
    ratProductsDivisionWO,
    ratProductsDivisionW,
    ratProductsSourceF,
    ratProductsSourceD,
    ratProductsSourceS,
    ratProductsSourceO,
    sumPrice,
    ratPriceSourceF,
    ratPriceSourceD,
    ratPriceSourceS,
    ratPriceSourceO,
    avgProducts,
    stdProducts,
    avgPrice,
    stdPrice
  FROM data_customer_prep c
  LEFT JOIN data_session_prep s
  ON c.customerId2 = s.customerId2
  LEFT JOIN data_returns_prep rt
  ON c.customerId2 = rt.customerId2
  INNER JOIN data_receipts_prep rc
  ON c.customerId2 = rc.customerId2
  ")

  return(customer)
}
