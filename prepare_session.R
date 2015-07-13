
prepare_session <- function (data_session, today) {

data_session$weekday <- weekdays(data_session$startTime, abbreviate=TRUE)

data_session <- data_session %>% group_by(customerId2) %>%
  mutate(rank = rank(startTime, ties.method="first")) %>%
  arrange(startTime)

data_session2 <- sqldf("
  SELECT
    s1.customerId2,
    s1.startTime,
    case when s1.weekday in ('Sat','Sun') then 1 
      else 0 end as weekend,
    s1.startTime-s2.startTime as interval,
    case when s1.site like '%UK%' and s1.productsPurchasedTotalCount>0 then 'UK'
      else case when s1.site like '%US' and s1.productsPurchasedTotalCount>0 then 'United States'
      else case when s1.site like '%FR' and s1.productsPurchasedTotalCount>0 then 'France'
      else case when s1.site like '%AU' and s1.productsPurchasedTotalCount>0 then 'Australia'
      else case when s1.site like '%DE' and s1.productsPurchasedTotalCount>0 then 'Germany'
      else case when s1.site like '%IT' and s1.productsPurchasedTotalCount>0 then 'Italy'
      else case when s1.site like '%ES' and s1.productsPurchasedTotalCount>0 then 'Spain'
      else case when s1.site like '%RU' and s1.productsPurchasedTotalCount>0 then 'Russia'
      else NULL end end end end end end end end as siteCountryPurchased,
    case when s1.userAgent like '%iPad%' then 'iPad' 
      else case when s1.userAgent like '%Tab%' or s1.userAgent like '%Nexus%' or s1.userAgent like '%Pad%' then 'OtherTablet'
      else case when s1.userAgent like '%Blackberry%' then 'Blackberry'
      else case when s1.userAgent like '%Android%' then 'AndroidPhone'
      else case when s1.userAgent like '%iPhone%' then 'iPhone'
      else case when s1.userAgent like '%Macintosh%' then 'Mac'
      else case when s1.userAgent like '%Windows%' then 'Windows'
      else case when s1.userAgent like '%Linux%' then 'Linux'
      else 'Other'
      end end end end end end end end as device,
    s1.pageViewCount,
    s1.nonPageViewEventsCount,
    s1.productViewCount,
    s1.productsAddedToBagCount,
    s1.productsSavedForLaterFromProductPageCount+s1.productsSavedForLaterFromCategoryPageCount
      as productsSavedForLaterCount,
    s1.productsPurchasedTotalCount
  FROM data_session s1
  LEFT JOIN data_session s2
  ON s2.rank = s1.rank - 1
    AND s2.customerId2 = s1.customerId2")

data_session3 <- fn$sqldf("
  SELECT
    customerId2,
    max(startTime)-min(startTime)+1 as periodActivity,
    $today-max(startTime) as periodActivityLastToday,
    avg(interval) as avgInterval,
    stdev(interval) as stdInterval,
    count(*) as nSessions,
    sum(case when weekend=1 then 1.0 else 0 end)/count(*) as ratSessionWeekend,
    max(siteCountryPurchased) as siteCountryPurchased,
    count(distinct device) as nDevices,
    sum(case when device like '%Phone' or device like 'Blackberry' then 1.0 else 0.0 end)/count(*) as ratPhone,
    sum(case when device like 'iPad' or device like 'OtherTablet' then 1.0 else 0.0 end)/count(*) as ratTablet,
    sum(case when device like 'Windows' or device like 'Mac' or device like 'Linux' then 1.0 else 0.0 end)/count(*) as ratComputer,
    avg(pageViewCount) as avgPageViewCount,
    avg(nonPageViewEventsCount) as avgNonPageViewEventsCount,
    avg(productViewCount) as avgProductViewCount,
    avg(productsAddedToBagCount) as avgProductsAddedToBagCount,
    avg(productsSavedForLaterCount) as avgProductsSavedForLaterCount,
    avg(productsPurchasedTotalCount) as avgProductsPurchasedTotalCount,
    sum(pageViewCount)/(max(startTime)-min(startTime)+1) as avgPageViewCount2,
    sum(nonPageViewEventsCount)/(max(startTime)-min(startTime)+1) as avgNonPageViewEventsCount2,
    sum(productViewCount)/(max(startTime)-min(startTime)+1) as avgProductViewCount2,
    sum(productsAddedToBagCount)/(max(startTime)-min(startTime)+1) as avgProductsAddedToBagCount2,
    sum(productsSavedForLaterCount)/(max(startTime)-min(startTime)+1) as avgProductsSavedForLaterCount2,
    sum(productsPurchasedTotalCount)/(max(startTime)-min(startTime)+1) as avgProductsPurchasedTotalCount2  
  FROM data_session2
  GROUP BY customerId2")

return(data_session3)

}
