-- ============================================================
--  SAMPLE DATA — Online Retail Sales Database
--  ~300+ records across all tables
-- ============================================================

-- ============================================================
--  COUNTRIES, STATES, CITIES
-- ============================================================

INSERT INTO countries (country_name, country_code) VALUES
('India',          'IN'),
('United States',  'US'),
('United Kingdom', 'GB');

INSERT INTO states (state_name, country_id) VALUES
('Tamil Nadu',         1), ('Maharashtra',      1), ('Karnataka',     1),
('Delhi',              1), ('West Bengal',       1), ('Telangana',     1),
('California',         2), ('New York',          2), ('Texas',         2),
('England',            3);

INSERT INTO cities (city_name, state_id, pincode) VALUES
('Chennai',      1, '600001'), ('Coimbatore',  1, '641001'), ('Madurai',     1, '625001'),
('Puducherry',   1, '605001'), ('Mumbai',      2, '400001'), ('Pune',        2, '411001'),
('Bengaluru',    3, '560001'), ('Mysuru',      3, '570001'), ('New Delhi',   4, '110001'),
('Kolkata',      5, '700001'), ('Hyderabad',   6, '500001'), ('Los Angeles', 7, '90001'),
('San Francisco',7, '94102'), ('New York City',8, '10001'),  ('Houston',     9, '77001'),
('London',      10, 'EC1A1');

-- ============================================================
--  CATEGORIES (with sub-categories)
-- ============================================================

INSERT INTO categories (category_name, parent_id, description) VALUES
('Electronics',        NULL, 'Electronic gadgets and devices'),
('Fashion',            NULL, 'Clothing, footwear and accessories'),
('Home & Kitchen',     NULL, 'Furniture, appliances and kitchenware'),
('Books',              NULL, 'Physical and digital books'),
('Sports & Fitness',   NULL, 'Sporting goods and fitness equipment'),
('Beauty & Health',    NULL, 'Personal care and wellness products'),
('Mobiles & Tablets',  1,    'Smartphones and tablets'),
('Laptops',            1,    'Laptops and accessories'),
('Cameras',            1,    'DSLR, mirrorless and action cameras'),
('Audio',              1,    'Headphones, speakers and earphones'),
('Men''s Clothing',    2,    'Shirts, trousers, ethnic wear for men'),
('Women''s Clothing',  2,    'Dresses, kurtas, ethnic wear for women'),
('Footwear',           2,    'Shoes, sandals and sports shoes'),
('Kitchen Appliances', 3,    'Mixers, ovens, coffee makers'),
('Furniture',          3,    'Beds, sofas, tables and chairs'),
('Fiction',            4,    'Novels and short story collections'),
('Non-Fiction',        4,    'Biographies, self-help, business books'),
('Gym Equipment',      5,    'Dumbbells, benches, resistance bands'),
('Skincare',           6,    'Face wash, moisturizers, serums');

-- ============================================================
--  SUPPLIERS
-- ============================================================

INSERT INTO suppliers (supplier_name, contact_email, contact_phone, city_id) VALUES
('TechWorld Distributors',   'supply@techworld.in',     '9841001001', 1),
('FashionHub India',         'orders@fashionhub.in',    '9823002002', 5),
('HomeEssentials Co.',       'contact@homeessentials.in','9845003003', 7),
('BookBazaar Publishers',    'books@bookbazaar.in',     '9812004004', 9),
('FitLife Supplies',         'info@fitlife.in',         '9867005005', 11),
('GlowBeauty Wholesale',     'sales@glowbeauty.in',     '9898006006', 5),
('ApexElectronics',          'apex@apexelec.in',        '9876007007', 7),
('StyleCraft Apparel',       'style@stylecraft.in',     '9834008008', 4);

-- ============================================================
--  PRODUCTS (50 products)
-- ============================================================

INSERT INTO products (product_name, sku, category_id, supplier_id, unit_price, cost_price, stock_quantity, reorder_level, discount_pct) VALUES
-- Mobiles & Tablets (cat 7)
('Samsung Galaxy S24',           'MOB-SAM-S24',    7, 1, 79999, 65000, 85,  10, 5.00),
('Apple iPhone 15',              'MOB-APL-IP15',   7, 1, 89999, 72000, 60,  10, 3.00),
('OnePlus 12R',                  'MOB-OP-12R',     7, 1, 39999, 31000, 120, 15, 8.00),
('Xiaomi Redmi Note 13',         'MOB-XMI-RN13',   7, 7, 18999, 13500, 200, 20, 10.00),
('Apple iPad Air 5',             'TAB-APL-IPA5',   7, 1, 59999, 48000, 45,  8,  4.00),

-- Laptops (cat 8)
('Dell XPS 15',                  'LAP-DEL-XPS15',  8, 7, 149999,120000, 30,  5,  5.00),
('Apple MacBook Air M2',         'LAP-APL-MBA-M2', 8, 1, 114999, 92000, 40,  5,  3.00),
('HP Pavilion 15',               'LAP-HP-PAV15',   8, 7, 62999,  49000, 75,  10, 7.00),
('Lenovo IdeaPad Slim 5',        'LAP-LNV-IPS5',   8, 7, 54999,  43000, 90,  10, 6.00),
('ASUS VivoBook 16',             'LAP-ASU-VB16',   8, 7, 49999,  39000, 65,  10, 5.00),

-- Audio (cat 10)
('Sony WH-1000XM5 Headphones',   'AUD-SNY-XM5',   10, 1, 29999, 22000, 110, 15, 8.00),
('boAt Rockerz 550',             'AUD-BOA-550',   10, 7, 1799,   1100, 500, 50, 15.00),
('JBL Flip 6 Speaker',           'AUD-JBL-FL6',   10, 7, 9999,   7500, 150, 20, 10.00),
('Apple AirPods Pro 2',          'AUD-APL-APP2',  10, 1, 24900,  19500, 80,  10, 5.00),
('Bose QuietComfort 45',         'AUD-BOS-QC45',  10, 1, 32999,  25000, 55,  8,  6.00),

-- Cameras (cat 9)
('Canon EOS R50',                'CAM-CNO-R50',    9, 1, 69999,  55000, 25,  5,  5.00),
('Sony Alpha A7 III',            'CAM-SNY-A7III',  9, 1,149999, 120000, 18,  3,  4.00),
('GoPro HERO 12',                'CAM-GPR-H12',    9, 7, 39999,  30000, 60,  8,  8.00),

-- Men's Clothing (cat 11)
('Levi''s 511 Slim Jeans',       'CLO-LEV-511',   11, 2, 2999,   1800, 300, 30, 10.00),
('Van Heusen Formal Shirt',      'CLO-VH-FS01',   11, 8, 1299,    750, 400, 40,  5.00),
('Allen Solly Chinos',           'CLO-AS-CHN',    11, 8, 1799,   1100, 250, 25, 12.00),
('Peter England Blazer',         'CLO-PE-BLZ',    11, 8, 3999,   2500, 100, 10,  8.00),
('Nike Dri-FIT T-Shirt',         'CLO-NKE-DFT',   11, 2, 1299,    800, 450, 50, 10.00),

-- Women's Clothing (cat 12)
('Biba Anarkali Kurta',          'CLO-BIB-ANK',   12, 2, 1899,   1100, 280, 30,  8.00),
('W for Woman Printed Dress',    'CLO-W4W-PD1',   12, 8, 1599,    950, 320, 30, 10.00),
('Fabindia Cotton Saree',        'CLO-FBI-CS1',   12, 2, 2499,   1600, 150, 15,  5.00),
('H&M Casual Top',               'CLO-HNM-CT1',   12, 2,  799,    450, 600, 60, 15.00),

-- Footwear (cat 13)
('Nike Air Max 270',             'FTW-NKE-AM270', 13, 2, 12995,   9000, 180, 20, 10.00),
('Adidas Ultraboost 22',         'FTW-ADI-UB22',  13, 2, 14999,  11000, 140, 15,  8.00),
('Puma Softride',                'FTW-PMA-SR1',   13, 2,  5999,   3800, 220, 25, 12.00),
('Red Tape Formal Shoes',        'FTW-RT-FM1',    13, 8,  2999,   1800, 200, 20,  5.00),

-- Kitchen Appliances (cat 14)
('Instant Pot Duo 7-in-1',       'KIT-INP-DUO7',  14, 3, 9999,   7200, 95,  10,  8.00),
('Philips Air Fryer HD9252',     'KIT-PHL-AF252',  14, 3, 8499,   6100, 110, 12,  6.00),
('Prestige Induction Cooktop',   'KIT-PRE-IC1',   14, 3, 3299,   2100, 180, 20,  5.00),
('Morphy Richards Toaster',      'KIT-MR-TST',    14, 3, 1999,   1200, 150, 15, 10.00),

-- Books (cat 16 fiction, 17 non-fiction)
('Atomic Habits - James Clear',  'BKS-AH-JC',     17, 4,  499,    180, 800, 80, 20.00),
('The Alchemist - Paulo Coelho', 'BKS-TAL-PC',    16, 4,  299,    110, 900, 90, 15.00),
('Zero to One - Peter Thiel',    'BKS-ZTO-PT',    17, 4,  599,    200, 600, 60, 18.00),
('Rich Dad Poor Dad',            'BKS-RDPD',      17, 4,  399,    150, 700, 70, 20.00),
('Harry Potter Box Set',         'BKS-HP-SET',    16, 4, 2499,   1500, 250, 25, 10.00),

-- Gym Equipment (cat 18)
('PowerBlock Adjustable Dumbbells','GYM-PB-ADB',  18, 5, 14999,  11000, 60,  8,  5.00),
('Boldfit Resistance Bands Set', 'GYM-BF-RBS',    18, 5,  699,    320, 800, 80, 20.00),
('Skipping Rope with Counter',   'GYM-SR-CNT',    18, 5,  399,    180, 600, 60, 15.00),
('Yoga Mat 6mm',                 'GYM-YM-6MM',    18, 5,  799,    400, 700, 70, 10.00),

-- Skincare (cat 19)
('Minimalist Niacinamide 10%',   'SKN-MIN-NIA',   19, 6,  599,    280, 1200,120, 15.00),
('Dot & Key Vitamin C Serum',    'SKN-DK-VCS',    19, 6,  899,    420, 900,  90, 12.00),
('Neutrogena Hydro Boost',       'SKN-NEU-HB',    19, 6, 1199,    650, 700,  70, 10.00),
('Himalaya Face Wash',           'SKN-HIM-FW',    19, 6,  149,     65, 2000, 200, 5.00),
('Mamaearth Onion Hair Oil',     'SKN-MME-OHO',   19, 6,  349,    160, 1500, 150, 8.00),

-- Furniture (cat 15)
('Wakefit Orthopaedic Mattress', 'FRN-WKF-OM',    15, 3, 12999,   9500, 40,  5,  6.00),
('Nilkamal Plastic Chair',       'FRN-NIL-CH1',   15, 3,  999,    550, 300, 30,  5.00);

-- ============================================================
--  CUSTOMERS (50 customers)
-- ============================================================

INSERT INTO customers (first_name, last_name, email, phone, gender, date_of_birth, loyalty_points) VALUES
('Aarav',     'Sharma',     'aarav.sharma@gmail.com',      '9841100001', 'M', '1995-03-12', 1250),
('Priya',     'Patel',      'priya.patel@yahoo.com',       '9823200002', 'F', '1992-07-24', 980),
('Ravi',      'Kumar',      'ravi.kumar@outlook.com',      '9845300003', 'M', '1988-11-05', 2100),
('Sneha',     'Iyer',       'sneha.iyer@gmail.com',        '9867400004', 'F', '1997-01-30', 450),
('Karthik',   'Nair',       'karthik.nair@gmail.com',      '9898500005', 'M', '1990-06-18', 3200),
('Deepika',   'Reddy',      'deepika.reddy@gmail.com',     '9812600006', 'F', '1994-09-22', 760),
('Arjun',     'Mehta',      'arjun.mehta@hotmail.com',     '9876700007', 'M', '1987-04-14', 1850),
('Kavya',     'Singh',      'kavya.singh@gmail.com',       '9834800008', 'F', '1999-12-03', 320),
('Vikram',    'Joshi',      'vikram.joshi@gmail.com',      '9841900009', 'M', '1985-08-27', 4100),
('Ananya',    'Gupta',      'ananya.gupta@gmail.com',      '9823010010', 'F', '1996-05-11', 670),
('Rohit',     'Verma',      'rohit.verma@gmail.com',       '9845110011', 'M', '1993-02-19', 1500),
('Meera',     'Pillai',     'meera.pillai@yahoo.com',      '9867220012', 'F', '1991-10-08', 890),
('Aditya',    'Bose',       'aditya.bose@gmail.com',       '9898330013', 'M', '1998-07-15', 220),
('Shreya',    'Das',        'shreya.das@gmail.com',        '9812440014', 'F', '1995-03-28', 1100),
('Nikhil',    'Rao',        'nikhil.rao@outlook.com',      '9876550015', 'M', '1989-12-01', 2800),
('Pooja',     'Mishra',     'pooja.mishra@gmail.com',      '9834660016', 'F', '1997-06-16', 540),
('Siddharth', 'Agarwal',    'siddharth.agarwal@gmail.com', '9841770017', 'M', '1986-09-23', 3600),
('Tanvi',     'Desai',      'tanvi.desai@gmail.com',       '9823880018', 'F', '1994-04-07', 710),
('Harsh',     'Shah',       'harsh.shah@gmail.com',        '9845990019', 'M', '1992-01-14', 1980),
('Nidhi',     'Chopra',     'nidhi.chopra@gmail.com',      '9867000020', 'F', '1990-11-29', 430),
('Manish',    'Tiwari',     'manish.tiwari@gmail.com',     '9898110021', 'M', '1988-07-04', 2250),
('Ritu',      'Srivastava', 'ritu.srivastava@yahoo.com',   '9812220022', 'F', '1996-02-17', 860),
('Abhishek',  'Pandey',     'abhishek.pandey@gmail.com',   '9876330023', 'M', '1993-05-30', 1620),
('Neha',      'Saxena',     'neha.saxena@gmail.com',       '9834440024', 'F', '1995-08-12', 390),
('Rahul',     'Yadav',      'rahul.yadav@gmail.com',       '9841550025', 'M', '1991-03-25', 2900),
('Divya',     'Krishnan',   'divya.krishnan@gmail.com',    '9823660026', 'F', '1987-10-19', 1340),
('Suresh',    'Menon',      'suresh.menon@gmail.com',      '9845770027', 'M', '1984-06-08', 4500),
('Preeti',    'Arora',      'preeti.arora@gmail.com',      '9867880028', 'F', '1998-01-21', 180),
('Amit',      'Bhatt',      'amit.bhatt@outlook.com',      '9898990029', 'M', '1990-09-14', 2700),
('Sunita',    'Kapoor',     'sunita.kapoor@gmail.com',     '9812000030', 'F', '1989-04-03', 960),
('Rajesh',    'Malhotra',   'rajesh.malhotra@gmail.com',   '9876110031', 'M', '1983-12-17', 5100),
('Archana',   'Nambiar',    'archana.nambiar@gmail.com',   '9834220032', 'F', '1994-07-26', 740),
('Gaurav',    'Trivedi',    'gaurav.trivedi@gmail.com',    '9841330033', 'M', '1992-02-09', 1760),
('Swati',     'Kulkarni',   'swati.kulkarni@gmail.com',    '9823440034', 'F', '1997-05-22', 510),
('Vivek',     'Goswami',    'vivek.goswami@gmail.com',     '9845550035', 'M', '1986-08-15', 3300),
('Isha',      'Jain',       'isha.jain@gmail.com',         '9867660036', 'F', '1995-11-28', 620),
('Pankaj',    'Dubey',      'pankaj.dubey@gmail.com',      '9898770037', 'M', '1988-03-11', 2150),
('Rekha',     'Ghosh',      'rekha.ghosh@yahoo.com',       '9812880038', 'F', '1993-06-24', 1080),
('Alok',      'Chatterjee', 'alok.chatterjee@gmail.com',   '9876990039', 'M', '1991-09-07', 1900),
('Vandana',   'Shetty',     'vandana.shetty@gmail.com',    '9834000040', 'F', '1996-12-20', 370),
('Sandeep',   'Banerjee',   'sandeep.banerjee@gmail.com',  '9841110041', 'M', '1985-04-02', 4200),
('Anita',     'Rajan',      'anita.rajan@gmail.com',       '9823220042', 'F', '1990-07-15', 830),
('Hemant',    'Thakur',     'hemant.thakur@gmail.com',     '9845330043', 'M', '1994-10-28', 1430),
('Preethi',   'Venkat',     'preethi.venkat@gmail.com',    '9867440044', 'F', '1997-01-11', 290),
('Naresh',    'Pillai',     'naresh.pillai@gmail.com',     '9898550045', 'M', '1987-05-24', 3750),
('Kavitha',   'Subramaniam','kavitha.sub@gmail.com',       '9812660046', 'F', '1992-08-07', 920),
('Balaji',    'Ramamurthy', 'balaji.ramu@gmail.com',       '9876770047', 'M', '1989-11-20', 2400),
('Lakshmi',   'Natarajan',  'lakshmi.nat@gmail.com',       '9834880048', 'F', '1995-02-03', 670),
('Vinod',     'Krishnaswamy','vinod.krish@gmail.com',      '9841990049', 'M', '1983-06-16', 5600),
('Saranya',   'Murugan',    'saranya.murugan@gmail.com',   '9823000050', 'F', '1998-09-29', 140);

-- ============================================================
--  ADDRESSES
-- ============================================================

INSERT INTO addresses (customer_id, address_line1, city_id, address_type, is_default) VALUES
(1,  '12, Anna Nagar 2nd Street',        1,  'HOME', TRUE),
(2,  '45 Linking Road, Bandra',          5,  'HOME', TRUE),
(3,  '8 MG Road, Indiranagar',           7,  'HOME', TRUE),
(4,  '23 Rathna Nagar',                  4,  'HOME', TRUE),
(5,  '101 Jubilee Hills',               11,  'HOME', TRUE),
(6,  '34 Salt Lake Sector V',           10,  'HOME', TRUE),
(7,  '78 Shivaji Park',                  5,  'WORK', TRUE),
(8,  '15 Koramangala 5th Block',         7,  'HOME', TRUE),
(9,  '90 Sector 15, Dwarka',             9,  'HOME', TRUE),
(10, '6 Civil Lines',                    9,  'HOME', TRUE),
(11, '22 Alwarpet',                      1,  'HOME', TRUE),
(12, '5 Powai Lake Drive',               5,  'HOME', TRUE),
(13, '44 HSR Layout',                    7,  'HOME', TRUE),
(14, '11 Park Street',                   10, 'HOME', TRUE),
(15, '3 Banjara Hills',                  11, 'HOME', TRUE),
(16, '18 Velachery Main Road',           1,  'HOME', TRUE),
(17, '29 Andheri West',                  5,  'HOME', TRUE),
(18, '67 BTM Layout 2nd Stage',          7,  'HOME', TRUE),
(19, '14 Nariman Point',                 5,  'WORK', TRUE),
(20, '52 Chandni Chowk',                 9,  'HOME', TRUE),
(21, '38 Secunderabad',                  11, 'HOME', TRUE),
(22, '7 Tollygunge',                     10, 'HOME', TRUE),
(23, '91 Kamla Nagar',                   9,  'HOME', TRUE),
(24, '26 Adyar',                         1,  'HOME', TRUE),
(25, '10 Malviya Nagar',                 9,  'HOME', TRUE),
(26, '55 Nandanam',                      1,  'HOME', TRUE),
(27, '3 Whitefield',                     7,  'HOME', TRUE),
(28, '17 Kothrud',                       6,  'HOME', TRUE),
(29, '43 Borivali West',                 5,  'HOME', TRUE),
(30, '8 JP Nagar',                       7,  'HOME', TRUE),
(31, '71 Lajpat Nagar',                  9,  'HOME', TRUE),
(32, '29 Calicut Road',                  8,  'HOME', TRUE),
(33, '16 Matunga East',                  5,  'HOME', TRUE),
(34, '4 Wakad',                          6,  'HOME', TRUE),
(35, '62 Basavangudi',                   7,  'HOME', TRUE),
(36, '11 T Nagar',                       1,  'HOME', TRUE),
(37, '50 Gomti Nagar',                   9,  'HOME', TRUE),
(38, '33 Behala',                        10, 'HOME', TRUE),
(39, '25 Rajarhat',                      10, 'HOME', TRUE),
(40, '9 Mangalore Road',                 8,  'HOME', TRUE),
(41, '76 Connaught Place',               9,  'HOME', TRUE),
(42, '14 Velankanni Nagar',              3,  'HOME', TRUE),
(43, '38 Sion West',                     5,  'HOME', TRUE),
(44, '2 Sholinganallur',                 1,  'HOME', TRUE),
(45, '60 Kukatpally',                    11, 'HOME', TRUE),
(46, '19 Tambaram',                      1,  'HOME', TRUE),
(47, '44 Yelahanka',                     7,  'HOME', TRUE),
(48, '7 Mylapore',                       1,  'HOME', TRUE),
(49, '88 Jayanagar',                     7,  'HOME', TRUE),
(50, '31 Chromepet',                     1,  'HOME', TRUE);

-- ============================================================
--  ORDERS (80 orders)
-- ============================================================

INSERT INTO orders (customer_id, shipping_address_id, order_date, expected_delivery, delivered_date, order_status, shipping_fee, discount_amount) VALUES
(1,  1,  '2024-01-05 10:23:00', '2024-01-10', '2024-01-09', 'DELIVERED',   49,  200),
(2,  2,  '2024-01-07 14:45:00', '2024-01-12', '2024-01-11', 'DELIVERED',   49,  150),
(3,  3,  '2024-01-10 09:15:00', '2024-01-15', '2024-01-14', 'DELIVERED',    0, 1000),
(4,  4,  '2024-01-12 16:30:00', '2024-01-17', NULL,          'CANCELLED',  49,    0),
(5,  5,  '2024-01-15 11:00:00', '2024-01-20', '2024-01-19', 'DELIVERED',    0, 2500),
(6,  6,  '2024-01-18 13:20:00', '2024-01-23', '2024-01-22', 'DELIVERED',   49,  100),
(7,  7,  '2024-01-20 08:45:00', '2024-01-25', '2024-01-24', 'DELIVERED',    0,  800),
(8,  8,  '2024-01-22 15:10:00', '2024-01-27', '2024-01-26', 'DELIVERED',   49,   50),
(9,  9,  '2024-01-25 10:30:00', '2024-01-30', '2024-01-29', 'DELIVERED',    0, 1500),
(10, 10, '2024-01-28 12:00:00', '2024-02-02', NULL,          'RETURNED',   49,    0),
(11, 11, '2024-02-02 09:45:00', '2024-02-07', '2024-02-06', 'DELIVERED',   49,  300),
(12, 12, '2024-02-05 14:20:00', '2024-02-10', '2024-02-09', 'DELIVERED',    0,  600),
(13, 13, '2024-02-08 11:15:00', '2024-02-13', '2024-02-12', 'DELIVERED',   49,   80),
(14, 14, '2024-02-10 16:40:00', '2024-02-15', '2024-02-14', 'DELIVERED',   49,  250),
(15, 15, '2024-02-12 10:00:00', '2024-02-17', '2024-02-16', 'DELIVERED',    0, 3000),
(16, 16, '2024-02-15 13:30:00', '2024-02-20', NULL,          'SHIPPED',    49,    0),
(17, 17, '2024-02-18 09:00:00', '2024-02-23', '2024-02-22', 'DELIVERED',    0, 1200),
(18, 18, '2024-02-20 15:45:00', '2024-02-25', '2024-02-24', 'DELIVERED',   49,  180),
(19, 19, '2024-02-22 11:20:00', '2024-02-27', '2024-02-26', 'DELIVERED',    0,  700),
(20, 20, '2024-02-25 14:00:00', '2024-03-01', '2024-02-29', 'DELIVERED',   49,  120),
(21, 21, '2024-03-01 10:15:00', '2024-03-06', '2024-03-05', 'DELIVERED',   49,  400),
(22, 22, '2024-03-03 12:30:00', '2024-03-08', '2024-03-07', 'DELIVERED',    0,  550),
(23, 23, '2024-03-06 09:45:00', '2024-03-11', '2024-03-10', 'DELIVERED',   49,   90),
(24, 24, '2024-03-09 15:00:00', '2024-03-14', NULL,          'CANCELLED',  49,    0),
(25, 25, '2024-03-12 11:30:00', '2024-03-17', '2024-03-16', 'DELIVERED',    0, 2000),
(26, 26, '2024-03-15 13:45:00', '2024-03-20', '2024-03-19', 'DELIVERED',   49,  350),
(27, 27, '2024-03-18 10:00:00', '2024-03-23', '2024-03-22', 'DELIVERED',    0, 1800),
(28, 28, '2024-03-20 14:15:00', '2024-03-25', '2024-03-24', 'DELIVERED',   49,  220),
(29, 29, '2024-03-23 09:30:00', '2024-03-28', '2024-03-27', 'DELIVERED',    0,  900),
(30, 30, '2024-03-26 12:45:00', '2024-03-31', '2024-03-30', 'DELIVERED',   49,  160),
(31, 31, '2024-04-01 10:00:00', '2024-04-06', '2024-04-05', 'DELIVERED',    0, 3500),
(32, 32, '2024-04-04 14:30:00', '2024-04-09', '2024-04-08', 'DELIVERED',   49,  280),
(33, 33, '2024-04-07 11:15:00', '2024-04-12', '2024-04-11', 'DELIVERED',   49,  130),
(34, 34, '2024-04-10 15:45:00', '2024-04-15', '2024-04-14', 'DELIVERED',    0,  750),
(35, 35, '2024-04-13 10:30:00', '2024-04-18', NULL,          'SHIPPED',     0,    0),
(36, 36, '2024-04-16 13:00:00', '2024-04-21', '2024-04-20', 'DELIVERED',   49,  200),
(37, 37, '2024-04-19 09:15:00', '2024-04-24', '2024-04-23', 'DELIVERED',    0, 1100),
(38, 38, '2024-04-22 14:45:00', '2024-04-27', '2024-04-26', 'DELIVERED',   49,  450),
(39, 39, '2024-04-25 11:00:00', '2024-04-30', '2024-04-29', 'DELIVERED',   49,  320),
(40, 40, '2024-04-28 12:30:00', '2024-05-03', '2024-05-02', 'DELIVERED',    0,  680),
(41, 41, '2024-05-02 10:45:00', '2024-05-07', '2024-05-06', 'DELIVERED',    0, 4000),
(42, 42, '2024-05-05 14:00:00', '2024-05-10', '2024-05-09', 'DELIVERED',   49,  190),
(43, 43, '2024-05-08 11:30:00', '2024-05-13', '2024-05-12', 'DELIVERED',   49,  260),
(44, 44, '2024-05-11 15:15:00', '2024-05-16', '2024-05-15', 'DELIVERED',    0,  580),
(45, 45, '2024-05-14 10:00:00', '2024-05-19', NULL,          'CANCELLED',  49,    0),
(46, 46, '2024-05-17 13:30:00', '2024-05-22', '2024-05-21', 'DELIVERED',   49,  140),
(47, 47, '2024-05-20 09:45:00', '2024-05-25', '2024-05-24', 'DELIVERED',    0, 1400),
(48, 48, '2024-05-23 14:20:00', '2024-05-28', '2024-05-27', 'DELIVERED',   49,  310),
(49, 49, '2024-05-26 11:05:00', '2024-05-31', '2024-05-30', 'DELIVERED',    0, 2200),
(50, 50, '2024-05-29 12:40:00', '2024-06-03', '2024-06-02', 'DELIVERED',   49,  170),
(1,  1,  '2024-06-03 10:20:00', '2024-06-08', '2024-06-07', 'DELIVERED',    0,  500),
(5,  5,  '2024-06-06 14:50:00', '2024-06-11', '2024-06-10', 'DELIVERED',    0, 1600),
(9,  9,  '2024-06-09 09:10:00', '2024-06-14', '2024-06-13', 'DELIVERED',    0, 2000),
(15, 15, '2024-06-12 15:35:00', '2024-06-17', '2024-06-16', 'DELIVERED',    0, 3200),
(17, 17, '2024-06-15 11:25:00', '2024-06-20', '2024-06-19', 'DELIVERED',    0,  900),
(21, 21, '2024-06-18 13:55:00', '2024-06-23', NULL,          'SHIPPED',    49,    0),
(25, 25, '2024-06-21 10:40:00', '2024-06-26', '2024-06-25', 'DELIVERED',    0, 1750),
(27, 27, '2024-06-24 14:10:00', '2024-06-29', '2024-06-28', 'DELIVERED',    0, 2500),
(31, 31, '2024-06-27 09:25:00', '2024-07-02', '2024-07-01', 'DELIVERED',    0, 4200),
(35, 35, '2024-06-30 12:00:00', '2024-07-05', '2024-07-04', 'DELIVERED',    0, 1300),
(3,  3,  '2024-07-04 10:50:00', '2024-07-09', '2024-07-08', 'DELIVERED',    0, 1500),
(7,  7,  '2024-07-07 15:20:00', '2024-07-12', '2024-07-11', 'DELIVERED',    0,  700),
(11, 11, '2024-07-10 11:40:00', '2024-07-15', '2024-07-14', 'DELIVERED',   49,  380),
(19, 19, '2024-07-13 13:10:00', '2024-07-18', NULL,          'PENDING',    49,    0),
(23, 23, '2024-07-16 10:05:00', '2024-07-21', '2024-07-20', 'DELIVERED',   49,  210),
(29, 29, '2024-07-19 14:35:00', '2024-07-24', '2024-07-23', 'DELIVERED',    0, 1050),
(33, 33, '2024-07-22 09:55:00', '2024-07-27', '2024-07-26', 'DELIVERED',   49,  290),
(37, 37, '2024-07-25 12:25:00', '2024-07-30', '2024-07-29', 'DELIVERED',    0,  820),
(41, 41, '2024-07-28 15:45:00', '2024-08-02', '2024-08-01', 'DELIVERED',    0, 3800),
(45, 45, '2024-07-31 10:15:00', '2024-08-05', '2024-08-04', 'DELIVERED',   49,  450),
(2,  2,  '2024-08-03 13:30:00', '2024-08-08', '2024-08-07', 'DELIVERED',   49,  200),
(6,  6,  '2024-08-06 11:00:00', '2024-08-11', '2024-08-10', 'DELIVERED',   49,  120),
(10, 10, '2024-08-09 14:50:00', '2024-08-14', NULL,          'SHIPPED',    49,    0),
(14, 14, '2024-08-12 10:20:00', '2024-08-17', '2024-08-16', 'DELIVERED',   49,  330),
(18, 18, '2024-08-15 12:40:00', '2024-08-20', '2024-08-19', 'DELIVERED',   49,  170),
(22, 22, '2024-08-18 09:00:00', '2024-08-23', '2024-08-22', 'DELIVERED',    0,  640),
(26, 26, '2024-08-21 15:10:00', '2024-08-26', '2024-08-25', 'DELIVERED',   49,  390),
(30, 30, '2024-08-24 11:30:00', '2024-08-29', '2024-08-28', 'DELIVERED',   49,  145),
(34, 34, '2024-08-27 13:50:00', '2024-09-01', '2024-08-31', 'DELIVERED',    0,  960),
(38, 38, '2024-08-30 10:10:00', '2024-09-04', '2024-09-03', 'DELIVERED',   49,  480);

-- ============================================================
--  ORDER ITEMS
-- ============================================================

INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(1,  4,  1, 18999,  10.00), (1,  36, 2,   499,  20.00),
(2,  24, 2,  1899,   8.00), (2,  44, 3,   899,  12.00),
(3,  7,  1,114999,   3.00), (3,  11, 1, 29999,   8.00),
(4,  20, 3,  1299,   5.00),
(5,  1,  1, 79999,   5.00), (5,  14, 1, 24900,   5.00),
(6,  25, 2,  1599,  10.00), (6,  43, 2,   149,   5.00),
(7,  6,  1,149999,   5.00), (7,  13, 1,  9999,  10.00),
(8,  28, 1, 12995,  10.00), (8,  42, 2,   699,  20.00),
(9,  2,  1, 89999,   3.00), (9,  10, 1, 49999,   5.00),
(10, 33, 1,  3299,   5.00), (10, 35, 2,   499,  20.00),
(11, 19, 2,  2999,  10.00), (11, 30, 1,  2999,   5.00),
(12, 17, 1,149999,   4.00), (12, 11, 1, 29999,   8.00),
(13, 37, 1,   599,  18.00), (13, 38, 2,   399,  20.00),
(14, 26, 1,  2499,   5.00), (14, 45, 2,   599,  15.00),
(15, 6,  1,149999,   5.00), (15, 7,  1,114999,   3.00),
(16, 23, 1,  1799,  12.00),
(17, 5,  1, 59999,   4.00), (17, 14, 1, 24900,   5.00),
(18, 24, 1,  1899,   8.00), (18, 27, 1,  1299,  10.00),
(19, 9,  1, 54999,   6.00), (19, 11, 1, 29999,   8.00),
(20, 32, 1,  8499,   6.00), (20, 43, 5,   149,   5.00),
(21, 3,  1, 39999,   8.00), (21, 22, 1,  3999,   8.00),
(22, 16, 1, 69999,   5.00),
(23, 40, 1,  6999,  10.00), (23, 41, 1,  5999,  12.00),
(24, 36, 3,   499,  20.00),
(25, 8,  1, 62999,   7.00), (25, 12, 1,  1799,  15.00),
(26, 47, 1, 12999,   6.00), (26, 49, 2,   149,   5.00),
(27, 1,  1, 79999,   5.00), (27, 15, 1, 32999,   6.00),
(28, 34, 1,  1999,  10.00), (28, 44, 2,   899,  12.00),
(29, 3,  1, 39999,   8.00), (29, 13, 1,  9999,  10.00),
(30, 37, 2,   599,  18.00), (30, 39, 1,  2499,  10.00),
(31, 2,  1, 89999,   3.00), (31, 6,  1,149999,   5.00),
(32, 21, 2,  1799,  12.00), (32, 42, 3,   699,  20.00),
(33, 35, 3,   499,  20.00), (33, 36, 2,   499,  20.00),
(34, 10, 1, 49999,   5.00), (34, 12, 1,  1799,  15.00),
(35, 9,  1, 54999,   6.00),
(36, 25, 2,  1599,  10.00), (36, 46, 1,   349,   8.00),
(37, 4,  2, 18999,  10.00), (37, 38, 3,   399,  20.00),
(38, 28, 1, 12995,  10.00), (38, 30, 1,  2999,   5.00),
(39, 26, 1,  2499,   5.00), (39, 45, 3,   599,  15.00),
(40, 32, 1,  8499,   6.00), (40, 43, 4,   149,   5.00),
(41, 1,  1, 79999,   5.00), (41, 7,  1,114999,   3.00),
(42, 19, 2,  2999,  10.00), (42, 23, 1,  1799,  12.00),
(43, 29, 1, 14999,   8.00), (43, 31, 1,  5999,   5.00),
(44, 16, 1, 69999,   5.00), (44, 18, 1, 39999,   8.00),
(45, 37, 2,   599,  18.00),
(46, 24, 2,  1899,   8.00), (46, 44, 2,   899,  12.00),
(47, 5,  1, 59999,   4.00), (47, 11, 1, 29999,   8.00),
(48, 20, 3,  1299,   5.00), (48, 22, 1,  3999,   8.00),
(49, 8,  1, 62999,   7.00), (49, 14, 1, 24900,   5.00),
(50, 25, 1,  1599,  10.00), (50, 46, 2,   349,   8.00),
(51, 3,  1, 39999,   8.00), (51, 36, 4,   499,  20.00),
(52, 1,  1, 79999,   5.00), (52, 15, 1, 32999,   6.00),
(53, 7,  1,114999,   3.00), (53, 11, 1, 29999,   8.00),
(54, 2,  1, 89999,   3.00), (54, 6,  1,149999,   5.00),
(55, 5,  1, 59999,   4.00), (55, 13, 1,  9999,  10.00),
(56, 4,  1, 18999,  10.00),
(57, 8,  1, 62999,   7.00), (57, 9,  1, 54999,   6.00),
(58, 1,  1, 79999,   5.00), (58, 16, 1, 69999,   5.00),
(59, 10, 1, 49999,   5.00),
(60, 3,  1, 39999,   8.00), (60, 21, 2,  1799,  12.00),
(61, 17, 1,149999,   4.00),
(62, 12, 2,  1799,  15.00), (62, 29, 1, 14999,   8.00),
(63, 9,  1, 54999,   6.00), (63, 14, 1, 24900,   5.00),
(64, 4,  1, 18999,  10.00), (64, 36, 3,   499,  20.00),
(65, 41, 1,  5999,  12.00), (65, 42, 2,   699,  20.00),
(66, 2,  1, 89999,   3.00),
(67, 6,  1,149999,   5.00), (67, 13, 1,  9999,  10.00),
(68, 24, 2,  1899,   8.00), (68, 27, 1,  1299,  10.00),
(69, 26, 1,  2499,   5.00), (69, 44, 2,   899,  12.00),
(70, 32, 1,  8499,   6.00), (70, 34, 1,  1999,  10.00),
(71, 1,  1, 79999,   5.00), (71, 7,  1,114999,   3.00),
(72, 19, 2,  2999,  10.00), (72, 30, 1,  2999,   5.00),
(73, 25, 1,  1599,  10.00), (73, 46, 2,   349,   8.00),
(74, 3,  1, 39999,   8.00), (74, 11, 1, 29999,   8.00),
(75, 8,  1, 62999,   7.00), (75, 12, 1,  1799,  15.00),
(76, 16, 1, 69999,   5.00),
(77, 5,  1, 59999,   4.00), (77, 14, 1, 24900,   5.00),
(78, 29, 1, 14999,   8.00), (78, 31, 1,  5999,   5.00),
(79, 9,  1, 54999,   6.00), (79, 13, 1,  9999,  10.00),
(80, 19, 1,  2999,  10.00), (80, 45, 3,   599,  15.00);

-- ============================================================
--  PAYMENTS
-- ============================================================

INSERT INTO payments (order_id, payment_date, amount, payment_method, payment_status, transaction_ref) VALUES
(1,  '2024-01-05 10:25:00', 19747,  'UPI',          'SUCCESS', 'TXN-2024-0001'),
(2,  '2024-01-07 14:47:00', 6415,   'CREDIT_CARD',  'SUCCESS', 'TXN-2024-0002'),
(3,  '2024-01-10 09:17:00', 143997, 'NET_BANKING',  'SUCCESS', 'TXN-2024-0003'),
(5,  '2024-01-15 11:02:00', 102374, 'CREDIT_CARD',  'SUCCESS', 'TXN-2024-0005'),
(6,  '2024-01-18 13:22:00', 3196,   'UPI',          'SUCCESS', 'TXN-2024-0006'),
(7,  '2024-01-20 08:47:00', 159198, 'DEBIT_CARD',   'SUCCESS', 'TXN-2024-0007'),
(8,  '2024-01-22 15:12:00', 13744,  'UPI',          'SUCCESS', 'TXN-2024-0008'),
(9,  '2024-01-25 10:32:00', 138498, 'CREDIT_CARD',  'SUCCESS', 'TXN-2024-0009'),
(10, '2024-01-28 12:02:00', 3447,   'COD',          'REFUNDED','TXN-2024-0010'),
(11, '2024-02-02 09:47:00', 8647,   'UPI',          'SUCCESS', 'TXN-2024-0011'),
(12, '2024-02-05 14:22:00', 142199, 'NET_BANKING',  'SUCCESS', 'TXN-2024-0012'),
(13, '2024-02-08 11:17:00', 1096,   'UPI',          'SUCCESS', 'TXN-2024-0013'),
(14, '2024-02-10 16:42:00', 3947,   'DEBIT_CARD',   'SUCCESS', 'TXN-2024-0014'),
(15, '2024-02-12 10:02:00', 261998, 'CREDIT_CARD',  'SUCCESS', 'TXN-2024-0015'),
(17, '2024-02-18 09:02:00', 83699,  'CREDIT_CARD',  'SUCCESS', 'TXN-2024-0017'),
(18, '2024-02-20 15:47:00', 3517,   'UPI',          'SUCCESS', 'TXN-2024-0018'),
(19, '2024-02-22 11:22:00', 83298,  'NET_BANKING',  'SUCCESS', 'TXN-2024-0019'),
(20, '2024-02-25 14:02:00', 8624,   'UPI',          'SUCCESS', 'TXN-2024-0020'),
(21, '2024-03-01 10:17:00', 42798,  'DEBIT_CARD',   'SUCCESS', 'TXN-2024-0021'),
(22, '2024-03-03 12:32:00', 66499,  'CREDIT_CARD',  'SUCCESS', 'TXN-2024-0022'),
(23, '2024-03-06 09:47:00', 11438,  'UPI',          'SUCCESS', 'TXN-2024-0023'),
(25, '2024-03-12 11:32:00', 61282,  'NET_BANKING',  'SUCCESS', 'TXN-2024-0025'),
(26, '2024-03-15 13:47:00', 13243,  'UPI',          'SUCCESS', 'TXN-2024-0026'),
(27, '2024-03-18 10:02:00', 110798, 'CREDIT_CARD',  'SUCCESS', 'TXN-2024-0027'),
(28, '2024-03-20 14:17:00', 3546,   'UPI',          'SUCCESS', 'TXN-2024-0028'),
(29, '2024-03-23 09:32:00', 49898,  'DEBIT_CARD',   'SUCCESS', 'TXN-2024-0029'),
(30, '2024-03-26 12:47:00', 1796,   'COD',          'SUCCESS', 'TXN-2024-0030'),
(31, '2024-04-01 10:02:00', 232498, 'CREDIT_CARD',  'SUCCESS', 'TXN-2024-0031'),
(32, '2024-04-04 14:32:00', 5567,   'UPI',          'SUCCESS', 'TXN-2024-0032'),
(33, '2024-04-07 11:17:00', 2147,   'UPI',          'SUCCESS', 'TXN-2024-0033'),
(34, '2024-04-10 15:47:00', 50548,  'NET_BANKING',  'SUCCESS', 'TXN-2024-0034'),
(36, '2024-04-16 13:02:00', 3447,   'UPI',          'SUCCESS', 'TXN-2024-0036'),
(37, '2024-04-19 09:17:00', 39744,  'DEBIT_CARD',   'SUCCESS', 'TXN-2024-0037'),
(38, '2024-04-22 14:47:00', 15943,  'CREDIT_CARD',  'SUCCESS', 'TXN-2024-0038'),
(39, '2024-04-25 11:02:00', 4147,   'UPI',          'SUCCESS', 'TXN-2024-0039'),
(40, '2024-04-28 12:32:00', 9295,   'UPI',          'SUCCESS', 'TXN-2024-0040'),
(41, '2024-05-02 10:47:00', 190498, 'CREDIT_CARD',  'SUCCESS', 'TXN-2024-0041'),
(42, '2024-05-05 14:02:00', 7646,   'UPI',          'SUCCESS', 'TXN-2024-0042'),
(43, '2024-05-08 11:32:00', 20238,  'DEBIT_CARD',   'SUCCESS', 'TXN-2024-0043'),
(44, '2024-05-11 15:17:00', 108418, 'NET_BANKING',  'SUCCESS', 'TXN-2024-0044'),
(46, '2024-05-17 13:32:00', 5246,   'UPI',          'SUCCESS', 'TXN-2024-0046'),
(47, '2024-05-20 09:47:00', 88298,  'CREDIT_CARD',  'SUCCESS', 'TXN-2024-0047'),
(48, '2024-05-23 14:22:00', 15695,  'UPI',          'SUCCESS', 'TXN-2024-0048'),
(49, '2024-05-26 11:07:00', 85149,  'DEBIT_CARD',   'SUCCESS', 'TXN-2024-0049'),
(50, '2024-05-29 12:42:00', 2517,   'COD',          'SUCCESS', 'TXN-2024-0050');

-- ============================================================
--  PRODUCT REVIEWS
-- ============================================================

INSERT INTO product_reviews (product_id, customer_id, order_id, rating, review_text) VALUES
(4,  1,  1,  5, 'Excellent phone! Great camera and battery life. Highly recommend.'),
(36, 1,  1,  4, 'Good read, very practical habits. Life changing book.'),
(24, 2,  2,  4, 'Beautiful kurta, great fabric quality. Fits perfectly.'),
(44, 2,  2,  3, 'Decent serum but results were slow. Will continue using.'),
(7,  3,  3,  5, 'MacBook M2 is phenomenal. Battery lasts all day easily.'),
(11, 3,  3,  5, 'Sony XM5 headphones are best in class. Worth every rupee.'),
(1,  5,  5,  5, 'Samsung Galaxy S24 camera is outstanding. Super fast processor.'),
(14, 5,  5,  4, 'AirPods Pro 2 sound amazing. Noise cancellation is superb.'),
(6,  7,  7,  5, 'Dell XPS 15 is a powerhouse. Display is gorgeous. Best laptop.'),
(2,  9,  9,  4, 'iPhone 15 is premium as always. Camera quality is top notch.'),
(10, 9,  9,  5, 'ASUS VivoBook is great value for money. Runs smooth.'),
(17, 12, 12, 5, 'Sony Alpha A7III takes breathtaking photos. Professional grade.'),
(11, 12, 12, 5, 'Second pair of Sony headphones. Never disappointed.'),
(37, 13, 13, 4, 'Zero to One is a must-read for entrepreneurs. Very insightful.'),
(38, 13, 13, 5, 'Rich Dad Poor Dad changed my perspective on money. Great book.'),
(8,  25, 25, 4, 'HP Pavilion is good for everyday tasks. Battery could be better.'),
(3,  21, 21, 4, 'OnePlus 12R is blazing fast. Great value flagship.'),
(16, 22, 22, 5, 'Canon R50 takes professional quality photos. Easy to learn.'),
(28, 8,  8,  4, 'Nike Air Max 270 are very comfortable for long walks.'),
(36, 30, 30, 5, 'Atomic Habits - best book I have ever read. Practical and impactful.');
