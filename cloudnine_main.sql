

PRAGMA foreign_keys = ON;
BEGIN;

CREATE TABLE region (
    regionId INTEGER PRIMARY KEY,
    regionName TEXT NOT NULL
);

CREATE TABLE availability_zone (
    availabilityZoneId INTEGER PRIMARY KEY,
    country TEXT NOT NULL,
    city TEXT NOT NULL,
    redundancy TEXT NOT NULL,
    connectivity TEXT NOT NULL,
    regulatoryEnvironment TEXT NOT NULL,
    regionId INTEGER NOT NULL REFERENCES region(regionId)
);

CREATE TABLE data_center (
    dataCenterId INTEGER PRIMARY KEY,
    availabilityZoneId INTEGER NOT NULL REFERENCES availability_zone(availabilityZoneId),
    dataCenterName TEXT NOT NULL
);

CREATE TABLE resource_type (
    resourceTypeId INTEGER PRIMARY KEY,
    typeName TEXT NOT NULL,
    capacityRating REAL NOT NULL CHECK (capacityRating > 0),
    intendedUse TEXT NOT NULL
);

CREATE TABLE resource_rate (
    resourceTypeId INTEGER PRIMARY KEY REFERENCES resource_type(resourceTypeId),
    hourlyRate NUMERIC NOT NULL CHECK (hourlyRate >= 0)
);

CREATE TABLE resource (
    resourceId INTEGER PRIMARY KEY,
    resourceTypeId INTEGER NOT NULL REFERENCES resource_type(resourceTypeId),
    dataCenterId INTEGER NOT NULL REFERENCES data_center(dataCenterId),
    resourceCode TEXT NOT NULL,
    performanceTier TEXT NOT NULL
);

CREATE TABLE staff (
    staffId INTEGER PRIMARY KEY,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    role TEXT NOT NULL,
    email TEXT NOT NULL,
    isActive INTEGER NOT NULL CHECK (isActive IN (0, 1))
);

CREATE TABLE resource_maintenance_log (
    logId INTEGER PRIMARY KEY,
    resourceId INTEGER NOT NULL REFERENCES resource(resourceId),
    staffId INTEGER NOT NULL REFERENCES staff(staffId),
    actionType TEXT NOT NULL,
    description TEXT NOT NULL,
    timestamp TEXT NOT NULL
);

CREATE TABLE client (
    clientId INTEGER PRIMARY KEY,
    clientName TEXT NOT NULL,
    clientType TEXT NOT NULL,
    contactEmail TEXT NOT NULL
);

CREATE TABLE reservation (
    reservationId INTEGER PRIMARY KEY,
    clientId INTEGER NOT NULL REFERENCES client(clientId),
    createdAt TEXT NOT NULL,
    status TEXT NOT NULL
);

CREATE TABLE reservation_requirement (
    requirementId INTEGER PRIMARY KEY,
    reservationId INTEGER NOT NULL REFERENCES reservation(reservationId),
    resourceTypeId INTEGER NOT NULL REFERENCES resource_type(resourceTypeId),
    regionId INTEGER NOT NULL REFERENCES region(regionId),
    startAt TEXT NOT NULL,
    endAt TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    requiredCapacity REAL NOT NULL CHECK (requiredCapacity > 0)
);

CREATE TABLE service (
    serviceId INTEGER PRIMARY KEY,
    serviceName TEXT NOT NULL
);

CREATE TABLE requirement_service (
    requirementId INTEGER NOT NULL REFERENCES reservation_requirement(requirementId),
    serviceId INTEGER NOT NULL REFERENCES service(serviceId),
    PRIMARY KEY (requirementId, serviceId)
);

CREATE TABLE project (
    projectId INTEGER PRIMARY KEY,
    clientId INTEGER NOT NULL REFERENCES client(clientId),
    projectName TEXT NOT NULL
);

CREATE TABLE deployment (
    deploymentId INTEGER PRIMARY KEY,
    reservationId INTEGER NOT NULL REFERENCES reservation(reservationId),
    projectId INTEGER NOT NULL REFERENCES project(projectId),
    staffId INTEGER NOT NULL REFERENCES staff(staffId),
    deploymentName TEXT NOT NULL
);

CREATE TABLE resource_assignment (
    assignmentId INTEGER PRIMARY KEY,
    requirementId INTEGER NOT NULL REFERENCES reservation_requirement(requirementId),
    resourceId INTEGER NOT NULL REFERENCES resource(resourceId),
    deploymentId INTEGER NOT NULL REFERENCES deployment(deploymentId),
    assignedFrom TEXT NOT NULL,
    assignedTo TEXT NOT NULL
);

CREATE TABLE usage_record (
    usageRecordId INTEGER PRIMARY KEY,
    assignmentId INTEGER NOT NULL REFERENCES resource_assignment(assignmentId),
    recordType TEXT NOT NULL,
    metricType TEXT NOT NULL,
    quantity REAL NOT NULL CHECK (quantity > 0),
    unit TEXT NOT NULL,
    periodStart TEXT NOT NULL,
    periodEnd TEXT NOT NULL
);

CREATE TABLE charge (
    chargeId INTEGER PRIMARY KEY,
    usageRecordId INTEGER NOT NULL REFERENCES usage_record(usageRecordId),
    chargeType TEXT NOT NULL,
    amount NUMERIC NOT NULL CHECK (amount >= 0),
    chargeDate TEXT NOT NULL
);

CREATE TABLE billing_account (
    billingAccountId INTEGER PRIMARY KEY,
    clientId INTEGER NOT NULL REFERENCES client(clientId),
    accountName TEXT NOT NULL
);

CREATE TABLE charge_allocation (
    billingAccountId INTEGER NOT NULL REFERENCES billing_account(billingAccountId),
    chargeId INTEGER NOT NULL REFERENCES charge(chargeId),
    percentage NUMERIC NOT NULL CHECK (percentage BETWEEN 0 AND 100),
    PRIMARY KEY (billingAccountId, chargeId)
);

CREATE TABLE client_payment_record (
    paymentRecordId INTEGER PRIMARY KEY,
    billingAccountId INTEGER NOT NULL REFERENCES billing_account(billingAccountId),
    amount NUMERIC NOT NULL CHECK (amount >= 0),
    paymentType TEXT NOT NULL,
    paymentMethod TEXT NOT NULL,
    transactionId TEXT NOT NULL,
    timestamp TEXT NOT NULL
);

CREATE TABLE user_credential (
    credentialId INTEGER PRIMARY KEY,
    clientId INTEGER NOT NULL REFERENCES client(clientId),
    credentialType TEXT NOT NULL,
    isActive INTEGER NOT NULL CHECK (isActive IN (0, 1))
);

CREATE TABLE support_ticket (
    ticketId INTEGER PRIMARY KEY,
    clientId INTEGER NOT NULL REFERENCES client(clientId),
    staffId INTEGER NOT NULL REFERENCES staff(staffId),
    description TEXT NOT NULL,
    severityLevel TEXT NOT NULL,
    status TEXT NOT NULL
);



--------INSERT statements GO HERE: POPULATE DATABASE WITH EXAMPLES:-------

INSERT INTO region (regionId, regionName) VALUES
(1,'US East'),
(2,'US East 2'),
(3,'US West'),
(4,'US Central'),
(5,'Canada Central'),
(6,'Brazil South'),
(7,'UK South'),
(8,'Ireland'),
(9,'France Central'),
(10,'Germany West'),
(11,'Sweden Central'),
(12,'India West'),
(13,'India South'),
(14,'Singapore'),
(15,'Japan East'),
(16,'South Korea'),
(17,'Australia East'),
(18,'UAE North'),
(19,'South Africa North'),
(20,'Hong Kong');

INSERT INTO availability_zone (availabilityZoneId, country, city, redundancy, connectivity, regulatoryEnvironment, regionId) VALUES
(1,'United States','Ashburn','2N','6 carriers, 400 Gbps','SOC 2, HIPAA-eligible',1),
(2,'United States','Columbus','N+1','4 carriers, 200 Gbps','SOC 2',2),
(3,'United States','San Jose','2N','5 carriers, 400 Gbps','SOC 2, HIPAA-eligible',3),
(4,'United States','Des Moines','N+1','3 carriers, 100 Gbps','SOC 2',4),
(5,'Canada','Toronto','N+1','4 carriers, 200 Gbps','PIPEDA, data residency',5),
(6,'Brazil','Sao Paulo','N+1','3 carriers, 100 Gbps','LGPD',6),
(7,'United Kingdom','London','2N','6 carriers, 400 Gbps','UK GDPR',7),
(8,'Ireland','Dublin','N+2','5 carriers, 200 Gbps','GDPR',8),
(9,'France','Paris','N+1','4 carriers, 200 Gbps','GDPR, HDS certified',9),
(10,'Germany','Frankfurt','2N','7 carriers, 400 Gbps','GDPR, BSI C5',10),
(11,'Sweden','Gavle','N+1','3 carriers, 100 Gbps','GDPR',11),
(12,'India','Mumbai','N+1','4 carriers, 200 Gbps','India data residency',12),
(13,'India','Chennai','N+1','3 carriers, 100 Gbps','India data residency',13),
(14,'Singapore','Singapore','2N','6 carriers, 400 Gbps','PDPA, MTCS',14),
(15,'Japan','Tokyo','2N','5 carriers, 400 Gbps','APPI',15),
(16,'South Korea','Seoul','N+1','4 carriers, 200 Gbps','PIPA',16),
(17,'Australia','Sydney','N+1','4 carriers, 200 Gbps','Privacy Act, IRAP',17),
(18,'United Arab Emirates','Dubai','N+1','3 carriers, 100 Gbps','UAE data residency',18),
(19,'South Africa','Johannesburg','N+1','3 carriers, 100 Gbps','POPIA',19),
(20,'Hong Kong','Hong Kong','N+1','4 carriers, 200 Gbps','PDPO',20);

INSERT INTO data_center (dataCenterId, availabilityZoneId, dataCenterName) VALUES
(1,1,'Ashburn DC1'),(2,2,'Columbus DC1'),(3,3,'San Jose DC1'),(4,4,'Des Moines DC1'),
(5,5,'Toronto DC1'),(6,6,'Sao Paulo DC1'),(7,7,'London DC1'),(8,8,'Dublin DC1'),
(9,9,'Paris DC1'),(10,10,'Frankfurt DC1'),(11,11,'Gavle DC1'),(12,12,'Mumbai DC1'),
(13,13,'Chennai DC1'),(14,14,'Singapore DC1'),(15,15,'Tokyo DC1'),(16,16,'Seoul DC1'),
(17,17,'Sydney DC1'),(18,18,'Dubai DC1'),(19,19,'Johannesburg DC1'),(20,20,'Hong Kong DC1');

INSERT INTO resource_type (resourceTypeId, typeName, capacityRating, intendedUse) VALUES
(1,'General Purpose Small',2,'General Purpose'),
(2,'General Purpose Medium',4,'General Purpose'),
(3,'General Purpose Large',8,'General Purpose'),
(4,'Compute Optimized',16,'Compute'),
(5,'Memory Optimized',32,'Memory'),
(6,'Storage Optimized',16,'Storage'),
(7,'GPU Training',48,'Machine Learning'),
(8,'GPU Inference',24,'Machine Learning'),
(9,'HPC Node',64,'High-Performance Computing'),
(10,'Data Analytics',32,'Data Analysis'),
(11,'Network Optimized',16,'Networking'),
(12,'Burstable Micro',1,'Development and Testing'),
(13,'Bare Metal',96,'Dedicated Workloads'),
(14,'Dedicated Storage Array',24,'Storage'),
(15,'Shared Storage Tier',8,'Storage'),
(16,'Cluster Bundle',48,'Clustered Deployment'),
(17,'High IOPS NVMe',16,'Storage'),
(18,'Edge Compute',4,'Edge Computing'),
(19,'Archive Storage',2,'Archival'),
(20,'Database Optimized',32,'Database');

INSERT INTO resource_rate (resourceTypeId, hourlyRate) VALUES
(1,0.05),(2,0.10),(3,0.20),(4,0.34),(5,0.50),(6,0.30),(7,3.00),(8,1.20),(9,2.50),(10,0.80),
(11,0.40),(12,0.02),(13,1.80),(14,0.60),(15,0.08),(16,1.50),(17,0.70),(18,0.15),(19,0.01),(20,0.90);

INSERT INTO resource (resourceId, resourceTypeId, dataCenterId, resourceCode, performanceTier) VALUES
(1,4,1,'USE1-R001','Premium'),
(2,7,2,'USE2-R002','High-Performance'),
(3,10,3,'USW1-R003','Premium'),
(4,13,4,'USC1-R004','High-Performance'),
(5,16,5,'CAC1-R005','Premium'),
(6,19,6,'BRS1-R006','Economy'),
(7,2,7,'UKS1-R007','Standard'),
(8,5,8,'IRL1-R008','Premium'),
(9,8,9,'FRC1-R009','High-Performance'),
(10,11,10,'DEW1-R010','Premium'),
(11,14,11,'SEC1-R011','Standard'),
(12,17,12,'INW1-R012','High-Performance'),
(13,20,13,'INS1-R013','Premium'),
(14,3,14,'SGP1-R014','Standard'),
(15,6,15,'JPE1-R015','Standard'),
(16,9,16,'KOR1-R016','High-Performance'),
(17,12,17,'AUE1-R017','Economy'),
(18,15,18,'UAE1-R018','Standard'),
(19,18,19,'ZAN1-R019','Standard'),
(20,1,20,'HKG1-R020','Standard');

INSERT INTO staff (staffId, firstName, lastName, role, email, isActive) VALUES
(1,'Priya','Nair','Operations Manager','priya.nair@cloudnine.example',1),
(2,'Daniel','Okafor','Site Reliability Engineer','daniel.okafor@cloudnine.example',1),
(3,'Sofia','Marino','Capacity Planner','sofia.marino@cloudnine.example',1),
(4,'Wei','Zhang','Operations Engineer','wei.zhang@cloudnine.example',1),
(5,'Amara','Diallo','Support Agent','amara.diallo@cloudnine.example',1),
(6,'Lucas','Meyer','Network Engineer','lucas.meyer@cloudnine.example',1),
(7,'Hannah','Kowalski','Billing Analyst','hannah.kowalski@cloudnine.example',0),
(8,'Rohan','Mehta','Site Reliability Engineer','rohan.mehta@cloudnine.example',1),
(9,'Elena','Petrova','Customer Support Lead','elena.petrova@cloudnine.example',1),
(10,'Marcus','Johnson','Operations Engineer','marcus.johnson@cloudnine.example',1),
(11,'Yuki','Tanaka','Network Engineer','yuki.tanaka@cloudnine.example',1),
(12,'Fatima','Al-Sayed','Support Agent','fatima.alsayed@cloudnine.example',1),
(13,'Tomas','Silva','Capacity Planner','tomas.silva@cloudnine.example',1),
(14,'Grace','Obi','Billing Analyst','grace.obi@cloudnine.example',1),
(15,'Oliver','Brown','Support Agent','oliver.brown@cloudnine.example',0),
(16,'Ananya','Rao','Operations Engineer','ananya.rao@cloudnine.example',1),
(17,'Jonas','Lindqvist','Site Reliability Engineer','jonas.lindqvist@cloudnine.example',1),
(18,'Camille','Dubois','Customer Support Lead','camille.dubois@cloudnine.example',1),
(19,'Kwame','Mensah','Operations Engineer','kwame.mensah@cloudnine.example',1),
(20,'Ines','Alvarez','Support Agent','ines.alvarez@cloudnine.example',1);

INSERT INTO resource_maintenance_log (logId, resourceId, staffId, actionType, description, timestamp) VALUES
(1,2,2,'Firmware Update','Applied GPU driver and firmware update','2026-09-28 02:00:00'),
(2,4,4,'Hardware Repair','Replaced failed memory module','2026-09-10 14:30:00'),
(3,6,10,'Scheduled Maintenance','Quarterly storage health check','2026-10-01 03:00:00'),
(4,8,16,'Reconfiguration','Adjusted memory allocation profile','2026-10-12 09:15:00'),
(5,10,6,'Failure Report','Network card dropped packets, flagged for repair','2026-10-20 18:45:00'),
(6,10,11,'Hardware Repair','Replaced network card','2026-10-21 10:00:00'),
(7,10,11,'Returned to Service','Throughput tests passed, resource back in service','2026-10-21 15:30:00'),
(8,12,17,'Scheduled Maintenance','NVMe wear-level check','2026-10-05 01:00:00'),
(9,13,19,'Firmware Update','Database node firmware update','2026-10-18 02:30:00'),
(10,1,8,'Scheduled Maintenance','Routine hypervisor patching','2026-09-20 02:30:00'),
(11,16,2,'Hardware Repair','Replaced cooling fan on HPC node','2026-10-15 11:20:00'),
(12,3,4,'Reconfiguration','Increased analytics memory limits','2026-09-25 13:00:00'),
(13,5,10,'Scheduled Maintenance','Cluster interconnect inspection','2026-10-08 04:00:00'),
(14,7,16,'Firmware Update','BIOS update on general purpose host','2026-09-30 01:45:00'),
(15,9,17,'Failure Report','GPU temperature warning, workload paused','2026-11-02 21:10:00'),
(16,11,19,'Scheduled Maintenance','Disk array rebuild verification','2026-10-22 03:15:00'),
(17,14,8,'Reconfiguration','Moved host to a different rack','2026-10-27 10:40:00'),
(18,15,2,'Hardware Repair','Replaced faulty storage controller','2026-11-05 15:25:00'),
(19,18,6,'Scheduled Maintenance','Shared storage firmware check','2026-11-09 02:00:00'),
(20,20,11,'Scheduled Maintenance','Routine network cable inspection','2026-11-12 05:30:00');

INSERT INTO client (clientId, clientName, clientType, contactEmail) VALUES
(1,'Brightwave Analytics','Organization','it@brightwave.example'),
(2,'Mira Sen','Individual','mira.kapoor@example.com'),
(3,'Northfield University Research Lab','Organization','labadmin@northfield.example'),
(4,'Lumen Media Group','Organization','ops@lumenmedia.example'),
(5,'Hearthstone Nonprofit Alliance','Organization','tech@hearthstone.example'),
(6,'Zephyr Labs','Team','team@zephyrlabs.example'),
(7,'Aarav Sharma','Individual','aarav.sharma@example.com'),
(8,'Coastline Logistics','Organization','it@coastlinelogistics.example'),
(9,'Pixel Forge Studio','Team','hello@pixelforge.example'),
(10,'Helios Energy','Organization','infra@helios.example'),
(11,'Tessa Brandt','Individual','tessa.brandt@example.com'),
(12,'Orbit Health Systems','Organization','cloud@orbithealth.example'),
(13,'GreenLeaf Education Trust','Organization','digital@greenleaf.example'),
(14,'Redwood Fintech','Organization','platform@redwoodfintech.example'),
(15,'Nimbus Dev Collective','Team','dev@nimbus.example'),
(16,'Samir Haddad','Individual','samir.haddad@example.com'),
(17,'Atlas Genomics Institute','Organization','compute@atlasgenomics.example'),
(18,'Bluebird Games','Team','tech@bluebirdgames.example'),
(19,'Lena Fischer','Individual','lena.fischer@example.com'),
(20,'Summit Retail Co.','Organization','it@summitretail.example');

INSERT INTO reservation (reservationId, clientId, createdAt, status) VALUES
(1,1,'2026-08-01 09:00:00','Completed'),
(2,2,'2026-08-02 09:00:00','Completed'),
(3,3,'2026-08-03 09:00:00','Completed'),
(4,4,'2026-08-04 09:00:00','Completed'),
(5,5,'2026-08-05 09:00:00','Completed'),
(6,6,'2026-08-06 09:00:00','Completed'),
(7,7,'2026-08-07 09:00:00','Active'),
(8,8,'2026-08-08 09:00:00','Active'),
(9,9,'2026-08-09 09:00:00','Active'),
(10,10,'2026-08-10 09:00:00','Active'),
(11,11,'2026-08-11 09:00:00','Active'),
(12,12,'2026-08-12 09:00:00','Active'),
(13,13,'2026-08-13 09:00:00','Active'),
(14,14,'2026-08-14 09:00:00','Active'),
(15,15,'2026-08-15 09:00:00','Active'),
(16,16,'2026-08-16 09:00:00','Active'),
(17,17,'2026-08-17 09:00:00','Active'),
(18,18,'2026-08-18 09:00:00','Active'),
(19,19,'2026-08-19 09:00:00','Active'),
(20,20,'2026-08-20 09:00:00','Active');

INSERT INTO reservation_requirement (requirementId, reservationId, resourceTypeId, regionId, startAt, endAt, quantity, requiredCapacity) VALUES
(1,1,4,1,'2026-09-01 08:00:00','2026-09-15 08:00:00',1,16),
(2,2,7,2,'2026-09-02 08:00:00','2026-09-30 08:00:00',1,40),
(3,3,10,3,'2026-09-03 08:00:00','2026-10-03 08:00:00',1,32),
(4,4,13,4,'2026-09-04 08:00:00','2026-09-18 08:00:00',1,64),
(5,5,16,5,'2026-09-05 08:00:00','2026-10-05 08:00:00',1,48),
(6,6,19,6,'2026-09-06 08:00:00','2026-09-20 08:00:00',1,2),
(7,7,2,7,'2026-09-07 08:00:00','2026-12-07 08:00:00',1,4),
(8,8,5,8,'2026-09-08 08:00:00','2026-11-30 08:00:00',1,32),
(9,9,8,9,'2026-09-09 08:00:00','2026-12-09 08:00:00',1,24),
(10,10,11,10,'2026-09-10 08:00:00','2026-11-24 08:00:00',1,12),
(11,11,14,11,'2026-09-11 08:00:00','2026-12-11 08:00:00',1,24),
(12,12,17,12,'2026-09-12 08:00:00','2026-12-31 08:00:00',1,16),
(13,13,20,13,'2026-09-13 08:00:00','2026-12-13 08:00:00',1,32),
(14,14,3,14,'2026-09-14 08:00:00','2026-11-28 08:00:00',1,8),
(15,15,6,15,'2026-09-15 08:00:00','2026-12-15 08:00:00',1,16),
(16,16,9,16,'2026-09-16 08:00:00','2026-12-16 08:00:00',1,64),
(17,17,12,17,'2026-09-17 08:00:00','2026-12-01 08:00:00',1,1),
(18,18,15,18,'2026-09-18 08:00:00','2026-12-18 08:00:00',1,8),
(19,19,18,19,'2026-09-19 08:00:00','2027-01-19 08:00:00',1,4),
(20,20,1,20,'2026-09-20 08:00:00','2027-03-20 08:00:00',1,2);

INSERT INTO service (serviceId, serviceName) VALUES
(1,'Premium Support'),
(2,'Daily Backups'),
(3,'Monitoring and Alerts'),
(4,'DDoS Protection'),
(5,'Load Balancing'),
(6,'Managed Database'),
(7,'Content Delivery Network'),
(8,'Log Archiving'),
(9,'Encrypted Storage'),
(10,'Disaster Recovery'),
(11,'Priority Provisioning'),
(12,'Auto Scaling'),
(13,'VPN Gateway'),
(14,'Compliance Reporting'),
(15,'Managed Kubernetes'),
(16,'Object Storage'),
(17,'Dedicated Network Link'),
(18,'Security Scanning'),
(19,'Off-Hours Support'),
(20,'Snapshot Storage');

INSERT INTO requirement_service (requirementId, serviceId) VALUES
(1,1),(1,2),(2,3),(2,13),(3,5),(4,4),(4,9),(5,6),(6,2),(7,3),
(8,8),(9,3),(9,10),(10,7),(11,2),(12,6),(13,11),(14,1),(16,12),(18,3);

INSERT INTO project (projectId, clientId, projectName) VALUES
(1,1,'Website Relaunch'),
(2,2,'Recommendation Model'),
(3,3,'Genomics Study'),
(4,4,'Documentary Rendering'),
(5,5,'Donor Platform Rebuild'),
(6,6,'Cold Data Archive'),
(7,7,'Personal Dev Sandbox'),
(8,8,'Route Optimization'),
(9,9,'Asset Pipeline'),
(10,10,'Smart Grid Ingest'),
(11,11,'Photo Library Backup'),
(12,12,'Patient Records Migration'),
(13,13,'Learning Platform Hosting'),
(14,14,'Credit Risk Modelling'),
(15,15,'Open Source Build Cache'),
(16,16,'Climate Simulation'),
(17,17,'Pipeline Test Automation'),
(18,18,'Game Asset Library'),
(19,19,'Portfolio Site'),
(20,20,'Storefront Prototype');

INSERT INTO deployment (deploymentId, reservationId, projectId, staffId, deploymentName) VALUES
(1,1,1,4,'brightwave-web-prod'),
(2,2,2,2,'kapoor-ml-training'),
(3,3,3,10,'northfield-genomics-analysis'),
(4,4,4,16,'lumen-video-render'),
(5,5,5,19,'hearthstone-donor-platform'),
(6,6,6,8,'zephyr-cold-archive'),
(7,7,7,4,'sharma-dev-sandbox'),
(8,8,8,17,'coastline-route-optimizer'),
(9,9,9,2,'pixelforge-asset-inference'),
(10,10,10,6,'helios-data-ingest-network'),
(11,11,11,10,'brandt-photo-archive'),
(12,12,12,11,'orbit-records-store'),
(13,13,13,16,'greenleaf-lms-database'),
(14,14,14,19,'redwood-risk-engine'),
(15,15,15,8,'nimbus-build-cache'),
(16,16,16,17,'haddad-simulation-run'),
(17,17,17,4,'atlas-test-runner'),
(18,18,18,10,'bluebird-asset-library'),
(19,19,19,11,'fischer-portfolio-edge'),
(20,20,20,2,'summit-storefront-prototype');

INSERT INTO resource_assignment (assignmentId, requirementId, resourceId, deploymentId, assignedFrom, assignedTo) VALUES
(1,1,1,1,'2026-09-01 08:00:00','2026-09-15 08:00:00'),
(2,2,2,2,'2026-09-02 08:00:00','2026-09-30 08:00:00'),
(3,3,3,3,'2026-09-03 08:00:00','2026-10-03 08:00:00'),
(4,4,4,4,'2026-09-04 08:00:00','2026-09-18 08:00:00'),
(5,5,5,5,'2026-09-05 08:00:00','2026-10-05 08:00:00'),
(6,6,6,6,'2026-09-06 08:00:00','2026-09-20 08:00:00'),
(7,7,7,7,'2026-09-07 08:00:00','2026-12-07 08:00:00'),
(8,8,8,8,'2026-09-08 08:00:00','2026-11-30 08:00:00'),
(9,9,9,9,'2026-09-09 08:00:00','2026-12-09 08:00:00'),
(10,10,10,10,'2026-09-10 08:00:00','2026-11-24 08:00:00'),
(11,11,11,11,'2026-09-11 08:00:00','2026-12-11 08:00:00'),
(12,12,12,12,'2026-09-12 08:00:00','2026-12-31 08:00:00'),
(13,13,13,13,'2026-09-13 08:00:00','2026-12-13 08:00:00'),
(14,14,14,14,'2026-09-14 08:00:00','2026-11-28 08:00:00'),
(15,15,15,15,'2026-09-15 08:00:00','2026-12-15 08:00:00'),
(16,16,16,16,'2026-09-16 08:00:00','2026-12-16 08:00:00'),
(17,17,17,17,'2026-09-17 08:00:00','2026-12-01 08:00:00'),
(18,18,18,18,'2026-09-18 08:00:00','2026-12-18 08:00:00'),
(19,19,19,19,'2026-09-19 08:00:00','2027-01-19 08:00:00'),
(20,20,20,20,'2026-09-20 08:00:00','2027-03-20 08:00:00');

INSERT INTO usage_record (usageRecordId, assignmentId, recordType, metricType, quantity, unit, periodStart, periodEnd) VALUES
(1,1,'actual','compute_hours',336,'hours','2026-09-01 08:00:00','2026-09-15 08:00:00'),
(2,2,'actual','compute_hours',672,'hours','2026-09-02 08:00:00','2026-09-30 08:00:00'),
(3,3,'actual','compute_hours',720,'hours','2026-09-03 08:00:00','2026-10-03 08:00:00'),
(4,4,'actual','compute_hours',336,'hours','2026-09-04 08:00:00','2026-09-18 08:00:00'),
(5,5,'actual','compute_hours',720,'hours','2026-09-05 08:00:00','2026-10-05 08:00:00'),
(6,6,'actual','storage',20000,'GB-month','2026-09-06 08:00:00','2026-09-20 08:00:00'),
(7,7,'estimated','compute_hours',2184,'hours','2026-09-07 08:00:00','2026-12-07 08:00:00'),
(8,8,'actual','compute_hours',1624,'hours','2026-09-08 08:00:00','2026-11-15 00:00:00'),
(9,9,'estimated','compute_hours',2184,'hours','2026-09-09 08:00:00','2026-12-09 08:00:00'),
(10,10,'actual','network_egress',12000,'GB','2026-09-10 08:00:00','2026-11-15 00:00:00'),
(11,11,'estimated','storage',8000,'GB-month','2026-09-11 08:00:00','2026-12-11 08:00:00'),
(12,12,'actual','storage',2500,'GB-month','2026-09-12 08:00:00','2026-11-15 00:00:00'),
(13,13,'estimated','compute_hours',2184,'hours','2026-09-13 08:00:00','2026-12-13 08:00:00'),
(14,14,'actual','compute_hours',1480,'hours','2026-09-14 08:00:00','2026-11-15 00:00:00'),
(15,15,'estimated','storage',6000,'GB-month','2026-09-15 08:00:00','2026-12-15 08:00:00'),
(16,16,'actual','compute_hours',1432,'hours','2026-09-16 08:00:00','2026-11-15 00:00:00'),
(17,17,'estimated','compute_hours',1800,'hours','2026-09-17 08:00:00','2026-12-01 08:00:00'),
(18,18,'actual','storage',10000,'GB-month','2026-09-18 08:00:00','2026-11-15 00:00:00'),
(19,19,'estimated','network_egress',3500,'GB','2026-09-19 08:00:00','2027-01-19 08:00:00'),
(20,20,'actual','compute_hours',1336,'hours','2026-09-20 08:00:00','2026-11-15 00:00:00');

INSERT INTO charge (chargeId, usageRecordId, chargeType, amount, chargeDate) VALUES
(1,1,'Compute Usage',114.24,'2026-09-16 09:00:00'),
(2,2,'Compute Usage',2016.00,'2026-10-01 09:00:00'),
(3,3,'Compute Usage',576.00,'2026-10-04 09:00:00'),
(4,4,'Compute Usage',604.80,'2026-09-19 09:00:00'),
(5,5,'Compute Usage',1080.00,'2026-10-06 09:00:00'),
(6,6,'Storage Consumption',80.00,'2026-09-21 09:00:00'),
(7,7,'Compute Usage',218.40,'2026-11-16 09:00:00'),
(8,8,'Compute Usage',812.00,'2026-11-16 09:00:00'),
(9,9,'Compute Usage',2620.80,'2026-11-16 09:00:00'),
(10,10,'Network Traffic',1080.00,'2026-11-16 09:00:00'),
(11,11,'Storage Consumption',400.00,'2026-11-16 09:00:00'),
(12,12,'Storage Consumption',300.00,'2026-11-16 09:00:00'),
(13,13,'Compute Usage',1965.60,'2026-11-16 09:00:00'),
(14,14,'Compute Usage',296.00,'2026-11-16 09:00:00'),
(15,15,'Storage Consumption',360.00,'2026-11-16 09:00:00'),
(16,16,'Compute Usage',3580.00,'2026-11-16 09:00:00'),
(17,17,'Compute Usage',36.00,'2026-11-16 09:00:00'),
(18,18,'Storage Consumption',300.00,'2026-11-16 09:00:00'),
(19,19,'Network Traffic',280.00,'2026-11-16 09:00:00'),
(20,20,'Compute Usage',66.80,'2026-11-16 09:00:00');

INSERT INTO billing_account (billingAccountId, clientId, accountName) VALUES
(1,1,'Brightwave - Main Account'),
(2,2,'Kapoor - Personal'),
(3,3,'Northfield Lab - Grant Account'),
(4,4,'Lumen Media - Main Account'),
(5,5,'Hearthstone - Program Budget'),
(6,6,'Zephyr Labs - Main Account'),
(7,7,'Sharma - Personal'),
(8,8,'Coastline - Operations'),
(9,9,'Pixel Forge - Main Account'),
(10,10,'Helios - Main Account'),
(11,11,'Brandt - Personal'),
(12,12,'Orbit Health - IT Department'),
(13,13,'GreenLeaf - Main Account'),
(14,14,'Redwood Fintech - Main Account'),
(15,15,'Nimbus - Main Account'),
(16,16,'Haddad - Personal'),
(17,17,'Atlas Genomics - Main Account'),
(18,18,'Bluebird Games - Main Account'),
(19,19,'Fischer - Personal'),
(20,20,'Summit Retail - Digital Team');

INSERT INTO charge_allocation (billingAccountId, chargeId, percentage) VALUES
(1,1,100),(2,2,100),(3,3,100),(4,4,100),(5,5,100),(6,6,100),(7,7,100),(8,8,100),
(9,9,100),(10,10,100),(11,11,100),(12,12,100),(13,13,100),(14,14,100),(15,15,100),(16,16,100),
(17,17,60),(3,17,40),
(18,18,50),(9,18,50),
(19,19,70),(7,19,30),
(20,20,80),(14,20,20);

INSERT INTO client_payment_record (paymentRecordId, billingAccountId, amount, paymentType, paymentMethod, transactionId, timestamp) VALUES
(1,1,500.00,'Deposit','Credit Card','TXN-100001','2026-08-28 10:15:00'),
(2,2,250.00,'Deposit','Credit Card','TXN-100002','2026-08-30 14:20:00'),
(3,3,1000.00,'Prepayment','Bank Transfer','TXN-100003','2026-08-31 09:05:00'),
(4,4,700.00,'Deposit','ACH','TXN-100004','2026-09-01 11:40:00'),
(5,5,1200.00,'Prepayment','Wire Transfer','TXN-100005','2026-09-02 16:10:00'),
(6,6,80.00,'Invoice Payment','Credit Card','TXN-100006','2026-09-22 13:25:00'),
(7,7,220.00,'Invoice Payment','Credit Card','TXN-100007','2026-10-05 08:50:00'),
(8,8,800.00,'Invoice Payment','Bank Transfer','TXN-100008','2026-10-07 15:30:00'),
(9,9,2500.00,'Invoice Payment','ACH','TXN-100009','2026-10-09 10:00:00'),
(10,10,1080.00,'Invoice Payment','Wire Transfer','TXN-100010','2026-10-12 12:45:00'),
(11,11,400.00,'Deposit','Credit Card','TXN-100011','2026-10-14 09:35:00'),
(12,12,300.00,'Invoice Payment','ACH','TXN-100012','2026-10-16 17:00:00'),
(13,13,2000.00,'Prepayment','Bank Transfer','TXN-100013','2026-10-19 11:10:00'),
(14,14,296.00,'Invoice Payment','Credit Card','TXN-100014','2026-10-21 14:55:00'),
(15,15,360.00,'Deposit','ACH','TXN-100015','2026-10-23 10:20:00'),
(16,16,100.00,'Refund','Credit Card','TXN-100016','2026-10-26 13:05:00'),
(17,17,600.00,'Invoice Payment','Bank Transfer','TXN-100017','2026-10-28 09:15:00'),
(18,18,150.00,'Invoice Payment','ACH','TXN-100018','2026-11-03 16:40:00'),
(19,19,112.00,'Invoice Payment','Credit Card','TXN-100019','2026-11-06 12:30:00'),
(20,20,33.40,'Invoice Payment','ACH','TXN-100020','2026-11-10 10:05:00');

INSERT INTO user_credential (credentialId, clientId, credentialType, isActive) VALUES
(1,1,'API Key',1),(2,2,'Password',1),(3,3,'Certificate',1),(4,4,'SSH Key',1),
(5,5,'Token',1),(6,6,'API Key',1),(7,7,'Password',0),(8,8,'Certificate',1),
(9,9,'SSH Key',1),(10,10,'Token',1),(11,11,'Password',1),(12,12,'Certificate',1),
(13,13,'API Key',1),(14,14,'Token',1),(15,15,'SSH Key',1),(16,16,'Password',1),
(17,17,'API Key',1),(18,18,'Token',0),(19,19,'Password',1),(20,20,'API Key',1);

INSERT INTO support_ticket (ticketId, clientId, staffId, description, severityLevel, status) VALUES
(1,1,5,'Intermittent latency on production web instances','High','Resolved'),
(2,2,12,'GPU instance failed to start after reservation window opened','Critical','Resolved'),
(3,3,5,'Request to extend reservation by two weeks','Low','Closed'),
(4,4,9,'Billing question about bare metal usage charges','Medium','In Progress'),
(5,5,18,'Unable to access cluster dashboard','High','Open'),
(6,6,12,'Please confirm archive retention settings','Low','Closed'),
(7,7,20,'Password reset email not received','Medium','Resolved'),
(8,8,9,'Memory usage alerts firing unexpectedly','Medium','In Progress'),
(9,9,5,'Inference jobs moved to a different resource without notice','High','Open'),
(10,10,18,'Network throughput below contracted level','Critical','In Progress'),
(11,11,20,'How to restore a deleted snapshot','Low','Resolved'),
(12,12,9,'Need confidentiality controls on deployment records','Medium','Open'),
(13,13,12,'Database failover test request','Low','Closed'),
(14,14,18,'Emergency support request for production outage','Critical','Resolved'),
(15,15,5,'Add new team member credentials','Low','Closed'),
(16,16,20,'Discount query for long-term commitment','Low','Open'),
(17,17,9,'Split billing across two departments','Medium','In Progress'),
(18,18,12,'Slow read speeds on shared storage','High','Open'),
(19,19,18,'Reservation start time change request','Low','Resolved'),
(20,20,5,'Invoice does not match estimated charges','Medium','Open');



