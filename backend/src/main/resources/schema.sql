CREATE TABLE IF NOT EXISTS passengers(id BIGSERIAL PRIMARY KEY, name VARCHAR(120) NOT NULL, email VARCHAR(180) UNIQUE NOT NULL, phone VARCHAR(30), password VARCHAR(120) NOT NULL DEFAULT 'demo123', points INT NOT NULL DEFAULT 0, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS routes(id BIGSERIAL PRIMARY KEY, route_code VARCHAR(30) UNIQUE NOT NULL, route_name VARCHAR(160) NOT NULL, origin VARCHAR(120), destination VARCHAR(120), demand INT DEFAULT 0);
CREATE TABLE IF NOT EXISTS buses(id BIGSERIAL PRIMARY KEY, bus_number VARCHAR(30) UNIQUE NOT NULL, route_id BIGINT REFERENCES routes(id), depot VARCHAR(120), status VARCHAR(40) DEFAULT 'ACTIVE');
CREATE TABLE IF NOT EXISTS surveys(id BIGSERIAL PRIMARY KEY, passenger_id BIGINT REFERENCES passengers(id), origin VARCHAR(120), destination VARCHAR(120), route_code VARCHAR(30), travel_time VARCHAR(40), waiting_minutes INT, overcrowding INT, rating INT, comments TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS bus_requests(id BIGSERIAL PRIMARY KEY, passenger_id BIGINT REFERENCES passengers(id), origin VARCHAR(120), destination VARCHAR(120), preferred_time VARCHAR(40), passengers_count INT DEFAULT 1, status VARCHAR(40) DEFAULT 'RECEIVED', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS incidents(id BIGSERIAL PRIMARY KEY, passenger_id BIGINT REFERENCES passengers(id), category VARCHAR(80), description TEXT, bus_number VARCHAR(30), route_code VARCHAR(30), location VARCHAR(180), urgency VARCHAR(30), evidence_name VARCHAR(255), evidence_sha256 VARCHAR(64), status VARCHAR(40) DEFAULT 'SUBMITTED', assigned_officer VARCHAR(120), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS complaint_updates(id BIGSERIAL PRIMARY KEY, incident_id BIGINT REFERENCES incidents(id) ON DELETE CASCADE, status VARCHAR(40), note TEXT, updated_by VARCHAR(120), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
INSERT INTO routes(route_code,route_name,origin,destination,demand) VALUES ('21G','Broadway – Tambaram','Broadway','Tambaram',86),('M18','T. Nagar – Guindy','T. Nagar','Guindy',72),('5E','Velachery – Parrys','Velachery','Parrys',64),('570S','Koyambedu – Siruseri','Koyambedu','Siruseri',91) ON CONFLICT(route_code) DO NOTHING;
INSERT INTO buses(bus_number,route_id,depot,status) SELECT 'TN01AB1234',id,'Tambaram Depot','ACTIVE' FROM routes WHERE route_code='21G' ON CONFLICT(bus_number) DO NOTHING;
INSERT INTO buses(bus_number,route_id,depot,status) SELECT 'TN01CD5678',id,'Guindy Depot','ACTIVE' FROM routes WHERE route_code='M18' ON CONFLICT(bus_number) DO NOTHING;
INSERT INTO officers(name,email,depot,role) VALUES ('Priya Raman','priya@transitvoice.demo','Tambaram Depot','Depot Officer'),('Arun Kumar','arun@transitvoice.demo','Guindy Depot','Safety Officer') ON CONFLICT(email) DO NOTHING;
INSERT INTO passengers(name,email,phone,password,points) VALUES ('Demo Passenger','passenger@demo.com','9876543210','demo123',120) ON CONFLICT(email) DO NOTHING;

ALTER TABLE incidents ADD COLUMN IF NOT EXISTS token VARCHAR(24);
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS evidence_path TEXT;
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS evidence_originality_status VARCHAR(40) DEFAULT 'NOT_CHECKED';
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS ai_checklist TEXT;
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS anonymous BOOLEAN DEFAULT TRUE;
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS is_rapid_sos BOOLEAN DEFAULT FALSE;
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS points_awarded BOOLEAN DEFAULT FALSE;
ALTER TABLE officers ADD COLUMN IF NOT EXISTS points INT NOT NULL DEFAULT 0;
UPDATE incidents SET token='TV-' || LPAD(id::text,6,'0') WHERE token IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS incidents_token_uq ON incidents(token);
CREATE INDEX IF NOT EXISTS incidents_evidence_hash_idx ON incidents(evidence_sha256);


-- Final capstone extensions: role accounts, bus journeys, live positions, dispatch and incentives.
ALTER TABLE officers ADD COLUMN IF NOT EXISTS phone VARCHAR(30);
ALTER TABLE officers ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);
ALTER TABLE officers ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;
ALTER TABLE officers ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;
ALTER TABLE officers ADD COLUMN IF NOT EXISTS available BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE officers ADD COLUMN IF NOT EXISTS station VARCHAR(120);
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMP;
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS arrived_at TIMESTAMP;
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS resolved_at TIMESTAMP;
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS sla_minutes INT NOT NULL DEFAULT 10;
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS driver_id BIGINT;
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS voice_path TEXT;
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS allocation_note TEXT;
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS escalation_level INT NOT NULL DEFAULT 0;
ALTER TABLE buses ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;
ALTER TABLE buses ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;
ALTER TABLE buses ADD COLUMN IF NOT EXISTS last_location_at TIMESTAMP;
ALTER TABLE buses ADD COLUMN IF NOT EXISTS driver_id BIGINT;
CREATE TABLE IF NOT EXISTS depots(id BIGSERIAL PRIMARY KEY,name VARCHAR(140) UNIQUE NOT NULL,latitude DOUBLE PRECISION,longitude DOUBLE PRECISION,manager_email VARCHAR(180),password_hash VARCHAR(255),created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS drivers(id BIGSERIAL PRIMARY KEY,name VARCHAR(120) NOT NULL,email VARCHAR(180) UNIQUE NOT NULL,phone VARCHAR(30) NOT NULL,password_hash VARCHAR(255) NOT NULL,bus_number VARCHAR(30),depot_id BIGINT REFERENCES depots(id),latitude DOUBLE PRECISION,longitude DOUBLE PRECISION,journey_active BOOLEAN NOT NULL DEFAULT FALSE,photo_path TEXT,last_location_at TIMESTAMP,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS incident_assignments(id BIGSERIAL PRIMARY KEY,incident_id BIGINT REFERENCES incidents(id) ON DELETE CASCADE,officer_id BIGINT REFERENCES officers(id),distance_km DOUBLE PRECISION,notified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,accepted_at TIMESTAMP,arrived_at TIMESTAMP,status VARCHAR(40) DEFAULT 'NOTIFIED',UNIQUE(incident_id,officer_id));
CREATE TABLE IF NOT EXISTS driver_notifications(id BIGSERIAL PRIMARY KEY,incident_id BIGINT REFERENCES incidents(id) ON DELETE CASCADE,driver_id BIGINT REFERENCES drivers(id),message TEXT NOT NULL,acknowledged BOOLEAN DEFAULT FALSE,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS incentive_ledger(id BIGSERIAL PRIMARY KEY,officer_id BIGINT REFERENCES officers(id),incident_id BIGINT REFERENCES incidents(id),points INT NOT NULL,reason VARCHAR(200),created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS withdrawal_requests(id BIGSERIAL PRIMARY KEY,officer_id BIGINT REFERENCES officers(id),amount_inr NUMERIC(10,2) NOT NULL,status VARCHAR(30) DEFAULT 'PENDING',requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,processed_at TIMESTAMP);
CREATE TABLE IF NOT EXISTS journey_logs(id BIGSERIAL PRIMARY KEY,driver_id BIGINT REFERENCES drivers(id),bus_number VARCHAR(30),latitude DOUBLE PRECISION,longitude DOUBLE PRECISION,photo_path TEXT,started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,ended_at TIMESTAMP);
INSERT INTO depots(name,latitude,longitude) VALUES ('Guindy Depot',13.0067,80.2206),('Tambaram Depot',12.9249,80.1000),('Koyambedu Depot',13.0694,80.1948) ON CONFLICT(name) DO NOTHING;

-- Built-in, distinct demo accounts. Admin is not an officer/depot account.
INSERT INTO officers(name,email,depot,role,phone,password_hash,station,available)
VALUES ('Arun Kumar','arun@transitvoice.demo','Guindy Depot','Safety Officer','9000000011','TVArun2026:eaa7d3105c8bb2694869c2557d072bdd4bcba9417eff165b4acbec57d7126d4e','Guindy Depot',TRUE)
ON CONFLICT(email) DO UPDATE SET password_hash=EXCLUDED.password_hash,phone=EXCLUDED.phone;
INSERT INTO officers(name,email,depot,role,phone,password_hash,station,available)
VALUES ('Priya Raman','priya.officer@transitvoice.demo','Tambaram Depot','Depot Officer','9000000022','TVPriya2026:81c6544710c61f557d653805edcd8ecead93a201b16fd8b9e2e8add49d48307c','Tambaram Depot',TRUE)
ON CONFLICT(email) DO UPDATE SET password_hash=EXCLUDED.password_hash,phone=EXCLUDED.phone;
UPDATE depots SET manager_email='depot.guindy@transitvoice.demo',password_hash='TVGuindy2026:163365348702b6bc7d0d8a47330cdbe276bba6c91eb45a90bb4074cb2e7e107d' WHERE name='Guindy Depot' AND (manager_email IS NULL OR manager_email='');
UPDATE depots SET manager_email='depot.tambaram@transitvoice.demo',password_hash='TVTambaram2026:81ee86abe361dfe59c9bd9f12b7ee3ed7908a5555741910fe6d2318929ace5c5' WHERE name='Tambaram Depot' AND (manager_email IS NULL OR manager_email='');
CREATE TABLE IF NOT EXISTS survey_settings(id INT PRIMARY KEY DEFAULT 1, is_open BOOLEAN NOT NULL DEFAULT FALSE, title VARCHAR(160) DEFAULT 'Weekly passenger travel survey', week_label VARCHAR(80), opens_at TIMESTAMP, closes_at TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
INSERT INTO survey_settings(id,is_open,title,week_label) VALUES(1,FALSE,'Weekly passenger travel survey','Weekly survey') ON CONFLICT(id) DO NOTHING;
CREATE TABLE IF NOT EXISTS survey_responses(id BIGSERIAL PRIMARY KEY, passenger_id BIGINT REFERENCES passengers(id), origin VARCHAR(120) NOT NULL,destination VARCHAR(120) NOT NULL,reason TEXT NOT NULL,preferred_time VARCHAR(50),passengers_count INT DEFAULT 1,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);


ALTER TABLE depots ADD COLUMN IF NOT EXISTS password_hash VARCHAR(64);


-- Passenger rewards, driver punctuality and demo Power BI-style reporting.
CREATE TABLE IF NOT EXISTS passenger_rewards(id BIGSERIAL PRIMARY KEY,passenger_id BIGINT REFERENCES passengers(id),incident_id BIGINT REFERENCES incidents(id),points INT NOT NULL,reason VARCHAR(200),created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,UNIQUE(passenger_id,incident_id));
CREATE TABLE IF NOT EXISTS reward_catalog(id BIGSERIAL PRIMARY KEY,title VARCHAR(160) NOT NULL,category VARCHAR(60),description TEXT,points_cost INT NOT NULL,partner_name VARCHAR(140),active BOOLEAN DEFAULT TRUE);
CREATE TABLE IF NOT EXISTS reward_redemptions(id BIGSERIAL PRIMARY KEY,passenger_id BIGINT REFERENCES passengers(id),reward_id BIGINT REFERENCES reward_catalog(id),points_spent INT NOT NULL,status VARCHAR(30) DEFAULT 'REQUESTED',redemption_code VARCHAR(32),created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS driver_points(id BIGSERIAL PRIMARY KEY,driver_id BIGINT REFERENCES drivers(id),journey_id BIGINT REFERENCES journey_logs(id),points INT NOT NULL,reason VARCHAR(200),created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
ALTER TABLE journey_logs ADD COLUMN IF NOT EXISTS route_code VARCHAR(30);
ALTER TABLE journey_logs ADD COLUMN IF NOT EXISTS route_name VARCHAR(160);
ALTER TABLE journey_logs ADD COLUMN IF NOT EXISTS scheduled_start TIMESTAMP;
ALTER TABLE journey_logs ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP;
ALTER TABLE journey_logs ADD COLUMN IF NOT EXISTS punctuality_minutes INT;
ALTER TABLE journey_logs ADD COLUMN IF NOT EXISTS points_awarded BOOLEAN DEFAULT FALSE;
INSERT INTO reward_catalog(title,category,description,points_cost,partner_name) VALUES
('₹50 Transit Cafe Voucher','Shop voucher','Demo voucher redeemable at participating cafe counter',500,'Transit Cafe (Demo)'),
('₹100 Bookstore Voucher','Shop voucher','Demo voucher for books and stationery',900,'City Books (Demo)'),
('Online Learning Course Coupon','Course','Demo access coupon for a beginner digital skills course',1200,'SkillSpring (Demo)'),
('₹200 Grocery Voucher','Shop voucher','Demo grocery voucher',1800,'Neighbour Mart (Demo)')
ON CONFLICT DO NOTHING;

-- Demo account and completed route for capstone presentation.
INSERT INTO routes(route_code,route_name,origin,destination,demand) VALUES('66P','Pallavaram to Vadapalani','Pallavaram','Vadapalani',75) ON CONFLICT(route_code) DO NOTHING;
INSERT INTO drivers(name,email,phone,password_hash,bus_number,depot_id,journey_active)
SELECT 'Demo Driver 66P','driver66p@transitvoice.demo','9000000066','TVdemo66P:023e68554ec51213e4ea0a1701a03c72963557fe30cfed880096c472ebd43d89','TN01TV0066',id,FALSE FROM depots WHERE name='Guindy Depot'
ON CONFLICT(email) DO UPDATE SET password_hash=EXCLUDED.password_hash,phone=EXCLUDED.phone;
INSERT INTO buses(bus_number,route_id,depot,status) SELECT 'TN01TV0066',id,'Guindy Depot','ACTIVE' FROM routes WHERE route_code='66P' ON CONFLICT(bus_number) DO NOTHING;
INSERT INTO journey_logs(driver_id,bus_number,route_code,route_name,started_at,scheduled_start,ended_at,completed_at,punctuality_minutes,points_awarded)
SELECT id,'TN01TV0066','66P','Pallavaram to Vadapalani',CURRENT_TIMESTAMP-INTERVAL '2 hours',CURRENT_TIMESTAMP-INTERVAL '2 hours 1 minute',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,1,TRUE FROM drivers WHERE email='driver66p@transitvoice.demo'
AND NOT EXISTS(SELECT 1 FROM journey_logs j JOIN drivers d ON d.id=j.driver_id WHERE d.email='driver66p@transitvoice.demo');
INSERT INTO driver_points(driver_id,journey_id,points,reason)
SELECT d.id,j.id,30,'Demo: on-time 66P journey' FROM drivers d JOIN journey_logs j ON j.driver_id=d.id WHERE d.email='driver66p@transitvoice.demo'
AND NOT EXISTS(SELECT 1 FROM driver_points p WHERE p.journey_id=j.id);

DELETE FROM reward_catalog a USING reward_catalog b WHERE a.id>b.id AND a.title=b.title;
CREATE UNIQUE INDEX IF NOT EXISTS reward_catalog_title_uq ON reward_catalog(title);
