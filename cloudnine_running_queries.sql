------QUERIES GO HERE SELECT FROM GROUP BY JOIN ; MAKE AND RESOLVE QUESTIONS (AT LEAST 6) ABOUT DATABASE
#1. Which regions have availability?
SELECT region.regionName, COUNT (resource.resourceId) AS freeResources
FROM region
JOIN availability_zone ON availability_zone.regionId = region.regionId
JOIN data_center ON availability_zone.availabilityZoneId = data_center.availabilityZoneId
JOIN resource ON resource.dataCenterId = data_center.dataCenterId
WHERE resource.resourceId NOT IN(
    SELECT resourceId FROM resource_assignment
    WHERE '2026-11-17' BETWEEN assignedFROM AND assignedTO
)
GROUP BY region.regionName
ORDER BY region.regionName;

#2. Which staff is handling which deployment?
SELECT staff.firstName, staff.lastName, deployment.deploymentName
FROM staff
JOIN deployment ON deployment.staffId = staff.staffId
ORDER BY staff.firstName;

#3 Which clients have not completed their payments?
SELECT client.clientName
FROM client
WHERE client.clientId NOT IN(
    SELECT billing_account.clientId
    FROM billing_account
    JOIN client_payment_record ON client_payment_record.billingAccountId = billing_account.billingAccountId
    WHERE client_payment_record.paymentType NOT LIKE '%Refund%')
ORDER BY client.clientName;

---#4. Which data centers are in which countries?
SELECT availability_zone.country, data_center.dataCenterName
FROM data_center
JOIN availability_zone
    ON availability_zone.availabilityZoneId=data_center.availabilityZoneId
ORDER BY availability_zone.country;

---#5. How many resources are in each performance tier?
SELECT deployment.deploymentName,
       resource.resourceCode,
       resource_maintenance_log.actionType,
       resource_maintenance_log.timestamp
FROM resource_maintenance_log
JOIN resource
  ON resource.resourceId = resource_maintenance_log.resourceId
JOIN resource_assignment
  ON resource_assignment.resourceId = resource_maintenance_log.resourceId
 AND resource_maintenance_log.timestamp
     BETWEEN resource_assignment.assignedFrom AND resource_assignment.assignedTo
JOIN deployment
  ON deployment.deploymentId = resource_assignment.deploymentId
WHERE resource_maintenance_log.actionType IN ('Failure Report', 'Hardware Repair')
ORDER BY resource_maintenance_log.timestamp;

--- #6. Which resource types generate the most revenue, and what share of total revenue does each bring in?
SELECT resource_type.typeName,
       resource_type.intendedUse,
       ROUND(SUM(charge.amount), 2) AS totalRevenue,
       ROUND(100.0 * SUM(charge.amount) / (SELECT SUM(charge.amount) FROM charge), 1) AS percentOfRevenue
FROM charge
JOIN usage_record
  ON usage_record.usageRecordId= charge.usageRecordId
JOIN resource_assignment
  ON resource_assignment.assignmentId= usage_record.assignmentId
JOIN resource
  ON resource.resourceId =resource_assignment.resourceId
JOIN resource_type
  ON resource_type.resourceTypeId=resource.resourceTypeId
GROUP BY resource_type.typeName, resource_type.intendedUse
ORDER BY totalRevenue DESC;

--- #7. Which services are requested most frequently, including services with no requests?
SELECT
    s.serviceName,
    COUNT(rs.requirementId) AS numberOfRequests
FROM service AS s
LEFT JOIN requirement_service AS rs
    ON s.serviceId = rs.serviceId
GROUP BY s.serviceId, s.serviceName
ORDER BY numberOfRequests DESC, s.serviceName;

--- #8. What types of maintenance activity occur for each resource type, and how frequently?
SELECT
    rt.typeName,
    m.actionType,
    COUNT(m.logId) AS eventCount
FROM resource_type AS rt
JOIN resource AS r
    ON rt.resourceTypeId = r.resourceTypeId
JOIN resource_maintenance_log AS m
    ON r.resourceId = m.resourceId
GROUP BY rt.resourceTypeId, rt.typeName, m.actionType
ORDER BY eventCount DESC, rt.typeName;

--- #9. Which resource types have the greatest actual usage within each metric and unit?
SELECT
    rt.typeName,
    u.metricType,
    u.unit,
    SUM(u.quantity) AS totalActualUsage
FROM usage_record AS u
JOIN resource_assignment AS ra
    ON u.assignmentId = ra.assignmentId
JOIN resource AS r
    ON ra.resourceId = r.resourceId
JOIN resource_type AS rt
    ON r.resourceTypeId = rt.resourceTypeId
WHERE u.recordType = 'actual'
GROUP BY
    rt.resourceTypeId,
    rt.typeName,
    u.metricType,
    u.unit
ORDER BY u.metricType, u.unit, totalActualUsage DESC;




