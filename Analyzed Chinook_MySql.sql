-- Tier 1: Basic retrieval, genre counts, album analysis, artist rankings

-- Q1: List all artists
SELECT ArtistId, Name 
FROM Artist;

-- Q2: Count albums per artist
SELECT a.Name, 
	COUNT(ab.AlbumId) AS AlbumCount
FROM Artist AS a
JOIN Album AS ab 
ON a.ArtistId = ab.ArtistId
GROUP BY a.Name;

-- Q3: Top 5 artists by album count
SELECT a.Name, 
	COUNT(ab.AlbumId) AS AlbumCount
FROM Artist AS a
JOIN Album AS ab 
ON a.ArtistId = ab.ArtistId
GROUP BY a.Name
ORDER BY AlbumCount DESC
LIMIT 5;

-- Q4: List all genres
SELECT GenreId, Name 
FROM genre;

-- Q5: Track count per genre
SELECT g.Name, 
	COUNT(t.TrackId) AS TrackCount
FROM genre AS g
JOIN track AS t 
ON g.GenreId = t.GenreId
GROUP BY g.Name;

-- Q6: Average track length per genre (minutes)- 60,000 milliseconds makes one minute 
SELECT g.Name, 
	AVG(Milliseconds/60000) AS AvgMinutes
FROM genre AS g
JOIN track AS t 
ON g.GenreId = t.GenreId
GROUP BY g.Name;

-- Q7: List all albums with track count
SELECT ab.Title, 
	COUNT(t.TrackId) AS TrackCount
FROM album AS ab
JOIN track AS t 
ON ab.AlbumId = t.AlbumId
GROUP BY ab.Title;

-- Q8: Top 5 albums by track count
SELECT ab.Title, 
	COUNT(t.TrackId) AS TrackCount
FROM Album AS ab
JOIN Track AS t 
ON ab.AlbumId = t.AlbumId
GROUP BY ab.Title
ORDER BY TrackCount DESC
LIMIT 5;

-- Q9: List all customers
SELECT CustomerId, FirstName, LastName 
FROM Customer;

-- Q10: Count customers per country
SELECT Country, 
	COUNT(*) AS Customers
FROM Customer
GROUP BY Country;

-- Q11: List invoices per customer
SELECT c.FirstName, c.LastName, 
	COUNT(i.InvoiceId) AS InvoiceCount
FROM Customer AS c
JOIN Invoice AS i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId;

-- Q12: Total sales per customer
SELECT c.FirstName, c.LastName, 
	SUM(i.Total) AS TotalSpent
FROM Customer AS c
JOIN Invoice AS i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId;

-- Tier 2: Unsold Tracks & Customer Patterns

-- Q13: List unsold tracks
SELECT t.Name
FROM track AS t
LEFT JOIN InvoiceLine AS il 
ON t.TrackId = il.TrackId
WHERE il.TrackId IS NULL;

-- Q14: Count unsold tracks per album
SELECT ab.Title, 
COUNT(t.TrackId) AS UnsoldTracks
FROM album AS ab
JOIN Track AS t 
ON ab.AlbumId = t.AlbumId
LEFT JOIN InvoiceLine AS il 
ON t.TrackId = il.TrackId
WHERE il.TrackId IS NULL
GROUP BY ab.Title;

-- Q15: Top-selling tracks
SELECT t.Name, 
	SUM(il.Quantity) AS SoldQty
FROM track AS t
JOIN InvoiceLine AS il 
ON t.TrackId = il.TrackId
GROUP BY t.Name
ORDER BY SoldQty DESC
LIMIT 10;

-- Q16: Top-selling artists
SELECT a.Name, 
	SUM(il.Quantity) AS SoldQty
FROM artist AS a
JOIN Album AS ab 
ON a.ArtistId = ab.ArtistId
JOIN Track AS t 
ON ab.AlbumId = t.AlbumId
JOIN InvoiceLine AS il 
ON t.TrackId = il.TrackId
GROUP BY a.Name
ORDER BY SoldQty DESC;

-- Q17: Customer purchase patterns
SELECT c.FirstName, c.LastName, 
	COUNT(i.InvoiceId) AS Orders, 
	SUM(i.Total) AS TotalSpent
FROM Customer AS c
JOIN Invoice AS i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId;

-- Q18: Favorite genre per customer (Top genre) based on frequency
WITH GenreCount AS (
  SELECT c.CustomerId, g.Name AS Genre, 
		COUNT(*) AS CountTracks,
         ROW_NUMBER() OVER(PARTITION BY c.CustomerId ORDER BY COUNT(*) DESC) AS rn
  FROM Customer AS c
  JOIN Invoice AS i 
  ON c.CustomerId = i.CustomerId
  JOIN InvoiceLine il 
  ON i.InvoiceId = il.InvoiceId
  JOIN Track AS t 
  ON il.TrackId = t.TrackId
  JOIN Genre AS g 
  ON t.GenreId = g.GenreId
  GROUP BY c.CustomerId, g.Name
)
SELECT CustomerId, Genre, CountTracks, rn
FROM GenreCount
WHERE rn = 1;

-- Q19: Customers with no purchases
SELECT c.FirstName, c.LastName
FROM Customer AS c
LEFT JOIN Invoice AS i 
ON c.CustomerId = i.CustomerId
WHERE i.InvoiceId IS NULL;

SELECT COUNT(*) AS TotalCustomers FROM Customer;

SELECT COUNT(DISTINCT CustomerId) AS CustomersWithInvoices FROM Invoice;

-- Q20: Average invoice amount per customer
SELECT c.FirstName, c.LastName, 
AVG(i.Total) AS AvgInvoice
FROM Customer AS c
JOIN Invoice AS i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId;

-- Q21: Most expensive tracks
SELECT Name, UnitPrice
FROM Track
ORDER BY UnitPrice DESC
LIMIT 10;

-- Q22: Albums without sales
SELECT ab.Title
FROM Album AS ab
LEFT JOIN Track t 
ON ab.AlbumId = t.AlbumId
LEFT JOIN InvoiceLine AS il 
ON t.TrackId = il.TrackId
WHERE il.TrackId IS NULL;

-- Q23: Total sales per genre
SELECT g.Name, 
	SUM(il.UnitPrice * il.Quantity) AS TotalSales
FROM genre AS g
JOIN track t ON g.GenreId = t.GenreId
JOIN InvoiceLine AS il 
ON t.TrackId = il.TrackId
GROUP BY g.Name
ORDER BY TotalSales DESC;

-- Q24: Top customers by revenue
SELECT c.FirstName, c.LastName, 
	SUM(i.Total) AS Revenue
FROM Customer AS c
JOIN Invoice AS i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY Revenue DESC
LIMIT 10;

-- Q25: Sales by country
SELECT c.Country, 
	SUM(i.Total) AS TotalSales
FROM Customer AS c
JOIN Invoice AS i 
ON c.CustomerId = i.CustomerId
GROUP BY c.Country;

-- Q26: Top 5 genres by sales
SELECT g.Name, 
	SUM(il.UnitPrice * il.Quantity) AS GenreSales
FROM genre AS g
JOIN track AS t 
ON g.GenreId = t.GenreId
JOIN InvoiceLine il 
ON t.TrackId = il.TrackId
GROUP BY g.Name
ORDER BY GenreSales DESC
LIMIT 5;

-- Q27: Customers with highest single invoice
SELECT c.FirstName, c.LastName, 
	MAX(i.Total) AS MaxInvoice
FROM customer AS c
JOIN invoice AS i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY MaxInvoice DESC
LIMIT 5;

-- Q28: Tracks that were never purchased
SELECT t.Name
FROM track AS t
LEFT JOIN invoiceLine AS il 
ON t.TrackId = il.TrackId
WHERE il.TrackId IS NULL;

-- Tier 3: Popularity & Running Totals

-- Q29: Track popularity index
SELECT t.Name, 
	SUM(il.Quantity) AS Popularity
FROM track AS t
JOIN InvoiceLine AS il 
ON t.TrackId = il.TrackId
GROUP BY t.Name
ORDER BY Popularity DESC;

-- Q30: Artist cross-genre count
SELECT a.Name, 
	COUNT(DISTINCT g.GenreId) AS GenreCount
FROM artist AS a
JOIN album AS ab 
ON a.ArtistId = ab.ArtistId
JOIN Track AS t 
ON ab.AlbumId = t.AlbumId
JOIN Genre g 
ON t.GenreId = g.GenreId
GROUP BY a.Name;

-- Q31: Running total sales
SELECT InvoiceDate, 
SUM(Total) OVER(ORDER BY InvoiceDate) AS RunningTotal
FROM Invoice;

-- Q32: Playlist track counts
SELECT pl.Name, 
	COUNT(pt.TrackId) AS TrackCount
FROM Playlist AS pl
JOIN PlaylistTrack AS pt 
ON pl.PlaylistId = pt.PlaylistId
GROUP BY pl.Name
ORDER BY TrackCount DESC;

-- Q33: Tracks in multiple playlists
SELECT t.Name, 
	COUNT(pt.PlaylistId) AS NumPlaylists
FROM track AS t
JOIN PlaylistTrack AS pt 
ON t.TrackId = pt.TrackId
GROUP BY t.Name
HAVING COUNT(pt.PlaylistId) > 1;

-- Q34: Most popular playlist
SELECT pl.Name, 
	COUNT(pt.TrackId) AS TrackCount
FROM playlist AS pl
JOIN PlaylistTrack AS pt 
ON pl.PlaylistId = pt.PlaylistId
GROUP BY pl.Name
ORDER BY TrackCount DESC
LIMIT 1;

-- Q35: Top 5 most popular tracks
SELECT t.Name, 
	SUM(il.Quantity) AS Popularity
FROM track AS t
JOIN InvoiceLine AS il 
ON t.TrackId = il.TrackId
GROUP BY t.Name
ORDER BY Popularity DESC
LIMIT 5;

-- Q36: Artist total sales
SELECT a.Name, 
	SUM(il.UnitPrice * il.Quantity) AS TotalSales
FROM artist AS a
JOIN album AS ab 
ON a.ArtistId = ab.ArtistId
JOIN track AS t 
ON ab.AlbumId = t.AlbumId
JOIN InvoiceLine il 
ON t.TrackId = il.TrackId
GROUP BY a.Name;

-- Q37: Genre popularity trend per year
SELECT YEAR(i.InvoiceDate) AS Year, g.Name, 
	SUM(il.Quantity) AS SoldQty
FROM genre AS g
JOIN Track AS t 
ON g.GenreId = t.GenreId
JOIN InvoiceLine AS il 
ON t.TrackId = il.TrackId
JOIN Invoice AS i 
ON il.InvoiceId = i.InvoiceId
GROUP BY Year, g.Name;

-- Q38: Running total per customer
SELECT c.CustomerId, i.InvoiceDate, 
	SUM(i.Total) OVER(PARTITION BY c.CustomerId 
	ORDER BY i.InvoiceDate) AS CustomerCumulative
FROM Customer AS c
JOIN Invoice AS i 
ON c.CustomerId = i.CustomerId;

-- Q39: Most frequent customer
SELECT c.FirstName, c.LastName, 
	COUNT(i.InvoiceId) AS NumInvoices
FROM customer AS c
JOIN invoice AS i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY NumInvoices DESC
LIMIT 1;

-- Q40: Track with highest revenue
SELECT t.Name, 
SUM(il.UnitPrice * il.Quantity) AS Revenue
FROM track AS t
JOIN invoiceLine AS il 
ON t.TrackId = il.TrackId
GROUP BY t.Name
ORDER BY Revenue DESC
LIMIT 1;

-- Q41: Average tracks per invoice
SELECT AVG(TrackCount) AS AvgTracks
FROM (
  SELECT i.InvoiceId, 
  COUNT(il.TrackId) AS TrackCount
  FROM Invoice AS i
  JOIN InvoiceLine AS il 
  ON i.InvoiceId = il.InvoiceId
  GROUP BY i.InvoiceId
) AS sub;

-- Q42: Playlist revenue
SELECT pl.Name, 
	SUM(il.UnitPrice * il.Quantity) AS Revenue
FROM playlist AS pl
JOIN playlistTrack AS pt 
ON pl.PlaylistId = pt.PlaylistId
JOIN track AS t 
ON pt.TrackId = t.TrackId
JOIN InvoiceLine AS il 
ON t.TrackId = il.TrackId
GROUP BY pl.Name;

-- Tier 4: Executive / Annual Reports

-- Q43: Annual revenue
SELECT YEAR(InvoiceDate) AS Year, 
	SUM(Total) AS Revenue
FROM Invoice
GROUP BY Year;

-- Q44: Customer LTV
SELECT c.FirstName, c.LastName, 
	SUM(i.Total) AS LTV
FROM Customer AS c
JOIN Invoice AS i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId;

-- Q45: Annual genre trend flags
SELECT g.Name, YEAR(i.InvoiceDate) AS Year, 
	SUM(il.Quantity) AS QtySold,
       CASE 
       WHEN SUM(il.Quantity) > LAG(SUM(il.Quantity)) OVER(PARTITION BY g.GenreId ORDER BY YEAR(i.InvoiceDate)) THEN 'Up' 
       ELSE 'Down' 
       END AS Trend
FROM genre AS g
JOIN track AS t 
ON g.GenreId = t.GenreId
JOIN InvoiceLine AS il 
ON t.TrackId = il.TrackId
JOIN Invoice AS i 
ON il.InvoiceId = i.InvoiceId
GROUP BY g.GenreId, Year;


-- Q46: Top 8 KPIs for CEO
WITH 
TotalRevenue AS (
    SELECT SUM(Total) AS Value FROM Invoice
),
TotalCustomers AS (
    SELECT COUNT(*) AS Value FROM Customer
),
TotalTracks AS (
    SELECT COUNT(*) AS Value FROM Track
),
AvgInvoice AS (
    SELECT AVG(Total) AS Value FROM Invoice
),
TopArtist AS (
    SELECT a.Name AS Value
    FROM Artist AS a
    JOIN Album AS ab ON a.ArtistId = al.ArtistId
    JOIN Track AS t ON ab.AlbumId = t.AlbumId
    JOIN InvoiceLine AS il ON t.TrackId = il.TrackId
    GROUP BY a.Name
    ORDER BY SUM(il.Quantity) DESC
    LIMIT 1
),
TopGenre AS (
    SELECT g.Name AS Value
    FROM Genre AS g
    JOIN Track AS t ON g.GenreId = t.GenreId
    JOIN InvoiceLine AS il ON t.TrackId = il.TrackId
    GROUP BY g.Name
    ORDER BY SUM(il.Quantity) DESC
    LIMIT 1
),
TopCustomer AS (
    SELECT CONCAT(c.FirstName,' ',c.LastName) AS Value
    FROM Customer AS c
    JOIN Invoice AS i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId
    ORDER BY SUM(i.Total) DESC
    LIMIT 1
),
AvgTracksPerInvoice AS (
    SELECT AVG(track_count) AS Value
    FROM (
        SELECT COUNT(il.TrackId) AS track_count
        FROM Invoice AS i
        JOIN InvoiceLine AS il ON i.InvoiceId = il.InvoiceId
        GROUP BY i.InvoiceId
    ) AS sub
)
SELECT 'Total Revenue' AS KPI, Value FROM TotalRevenue
UNION ALL
SELECT 'Total Customers', Value FROM TotalCustomers
UNION ALL
SELECT 'Total Tracks', Value FROM TotalTracks
UNION ALL
SELECT 'Average Invoice', Value FROM AvgInvoice
UNION ALL
SELECT 'Top Artist', Value FROM TopArtist
UNION ALL
SELECT 'Top Genre', Value FROM TopGenre
UNION ALL
SELECT 'Top Customer', Value FROM TopCustomer
UNION ALL
SELECT 'Average Tracks per Invoice', Value FROM AvgTracksPerInvoice;


-- Q47: Monthly revenue
SELECT YEAR(InvoiceDate) AS Year, 
	MONTH(InvoiceDate) AS Month, 
	SUM(Total) AS Revenue
FROM Invoice
GROUP BY Year, Month;

-- Q48: Customer purchase recency
SELECT c.FirstName, c.LastName, 
	MAX(i.InvoiceDate) AS LastPurchase
FROM customer AS c
JOIN invoice AS i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId;

-- Q49: Average revenue per track
SELECT SUM(il.UnitPrice * il.Quantity)/COUNT(DISTINCT t.TrackId) AS AvgRevenuePerTrack
FROM track AS t
JOIN InvoiceLine AS il 
ON t.TrackId = il.TrackId;


-- Q50: CEO Summary Table (Combine key metrics from Q43–Q49)
SELECT 
    -- Core KPIs
    SUM(i.Total) AS TotalRevenue,
    COUNT(DISTINCT c.CustomerId) AS TotalCustomers,
    COUNT(DISTINCT i.InvoiceId) AS TotalInvoices,
    AVG(i.Total) AS AvgInvoiceValue,
    SUM(il.Quantity) AS TotalTracksSold,

    -- Avg Tracks per Invoice
    (
        SELECT AVG(track_count)
        FROM (
            SELECT COUNT(il2.TrackId) AS track_count
            FROM InvoiceLine AS il2
            GROUP BY il2.InvoiceId
        ) sub
    ) AS AvgTracksPerInvoice,

    -- Top Genre
    (
        SELECT g.Name
        FROM Genre AS g
        JOIN Track AS t ON g.GenreId = t.GenreId
        JOIN InvoiceLine AS il3 ON t.TrackId = il3.TrackId
        GROUP BY g.Name
        ORDER BY SUM(il3.Quantity) DESC
        LIMIT 1
    ) AS TopGenre,

    -- Top Artist
    (
        SELECT a.Name
        FROM Artist AS a
        JOIN Album AS ab ON a.ArtistId = ab.ArtistId
        JOIN Track AS t ON ab.AlbumId = t.AlbumId
        JOIN InvoiceLine AS il4 ON t.TrackId = il4.TrackId
        GROUP BY a.Name
        ORDER BY SUM(il4.Quantity) DESC
        LIMIT 1
    ) AS TopArtist

FROM Invoice AS i
JOIN InvoiceLine AS il ON i.InvoiceId = il.InvoiceId
JOIN Customer AS c ON i.CustomerId = c.CustomerId;

-- Tracking Sales
SELECT 
    track.Name AS track_name,
    artist.Name AS artist,
    SUM(invoiceline.Quantity) AS total_units,
    SUM(invoiceline.UnitPrice * invoiceline.Quantity) AS revenue
FROM invoiceline 
JOIN track  ON invoiceline.TrackId = track.TrackId
JOIN album  ON track.AlbumId = album.AlbumId
JOIN artist ON album.ArtistId = artist.ArtistId
GROUP BY track.TrackId, track.Name, artist.Name
ORDER By revenue DESC;

SELECT * FROM playlisttrack;

SELECT * FROM album;

SELECT * FROM customer;

SELECT * FROM employee;

SELECT * FROM genre;

SELECT * FROM invoice;

SELECT * FROM invoiceline;

SELECT * FROM mediatype;

SELECT * FROM playlist;

SELECT * FROM artist;

SELECT * FROM track;

USE `Chinook`;