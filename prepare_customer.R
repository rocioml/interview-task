
prepare_customer <- function (data_customer, today) {

yearToday <- as.numeric(format(today, "%Y")) 
  
data_customer2 <- fn$sqldf("
  SELECT
    customerId2,
    churnlabel-1 as churn,
    case when gender='F' then 1 else 0 end as female,
    case when yearOfBirth<1944 or yearOfBirth>1999 then null else $yearToday-yearOfBirth end as age,
    $today-dateCreated as periodCreatedToday,
    case when premier=0 then 1 else 0 end as premierNever,
    case when premier=1 then 1 else 0 end as premier1,
    case when premier=2 then 1 else 0 end as premier2,
    case when premier=3 then 1 else 0 end as premier3,
    case when premier=4 then 1 else 0 end as premier4,
    case when premier=5 then 1 else 0 end as premier5,
    case when premier=6 then 1 else 0 end as premier6,
    case when premier>=1 and premier <=3 then 1 else 0 end as premierActive,
    case when premier>=4 then 1 else 0 end as premierPast,
    shippingCountry
  FROM data_customer")

return(data_customer2)

}
