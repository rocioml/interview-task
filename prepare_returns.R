
prepare_returns <- function (data_returns, today) {

data_returns2 <- fn$sqldf("
  SELECT
    customerId2,
    $today-max(signalDate) as periodReturnsLastToday,
    case when max(case when returnAction<>'Cancel' then signalDate else -1 end)=-1 then -1
      else $today-max(case when returnAction<>'Cancel' then signalDate else -1 end) end
      as periodReturnsNotCancelLastToday,
    sum(case when returnAction='Cancel' then 1 else 0 end) as nReturnActionCancel,
    sum(case when returnAction='Refund' then 1 else 0 end) as nReturnActionRefund,
    sum(case when returnAction='Replacement' then 1 else 0 end) as nReturnActionReplacement,
    sum(case when returnReason in ('Manual Cancel', '2. Ordered more than one size', 
      'Selected incorrect delivery method', 'Need to change payment method', 'No longer required',
      'Item(s) would not arrive on time') then 1 else 0 end) as nReturnReasonGrade1,
    sum(case when returnReason like '%t Fit properly' or returnReason like '%t suit me'
      or returnReason='No paperwork' then 1 else 0 end) as nReturnReasonGrade2,
    sum(case when returnReason in ('1. Looks Different to Image on site', '4b. Faulty', 
      'Lost in Transit (In dispute)', '4a. Poor Quality', 'Carrier Lost Return Item', 
      '3. Arrived too Late', '7. Incorrect Item Received', 'Wrong Item Received (Return Expected)',
      'Missing From Order', 'Item Faulty (Return Expected)', 'Shipping cost too high',
      'Item faulty (customer to destroy)') then 1 else 0 end) as nReturnReasonGrade3
  FROM data_returns
  GROUP BY customerId2")

return(data_returns2)

}
