
--Query 1
MATCH (src:Airport) -[route:Route]-> (:Airport)
RETURN src.airportname as Airport, count(route) as Flights
ORDER BY Flights DESC LIMIT 5;

-- Query 2
MATCH (src:Airport)
RETURN src.airportcountry as CountryName, count(src.airportname) as AirportCount
ORDER BY AirportCount DESC
LIMIT 5

-- Query 3
MATCH (airline:Airline) -[route]-> (airport:Airport)
WHERE airport.airportcountry = "Greece"
RETURN airline.airlinename as Airline, count(route) as Flights
ORDER BY Flights DESC LIMIT 5;

-- Query 4
MATCH (a:Airline) - [ffrom:fliesfrom] -> (airport:Airport) <- [fto:fliesto] - (a:Airline)
WHERE airport.airportcountry="Germany"
RETURN a.airlinename, count(airport) as Flights
ORDER BY Flights DESC
LIMIT 5;

--Query 5 
MATCH (src:Airport) -[route:Route]-> (dest:Airport)
WHERE dest.airportcountry  = "Greece" AND src.airportcountry  <> "Greece"
RETURN src.airportcountry  as Country, count(route) as Flights
ORDER BY Flights DESC LIMIT 10;

-- Query 6 
MATCH (src:Airport) -[outRoute:Route]-> (dest:Airport)
WHERE src.airportcountry = "Greece" AND dest.airportcountry <> "Greece"
WITH collect(outRoute) as outRoutes
WITH reduce(a = 0, n in outRoutes | a + 1) as totaloutRoutes
MATCH (src:Airport) -[inRoute:Route]-> (dest:Airport)
WHERE dest.airportcountry = "Greece" AND src.airportcountry <> "Greece"
WITH totaloutRoutes,
collect(inRoute) as inRoutes
WITH totaloutRoutes,
reduce(a = 0, n in inRoutes | a + 1) as totalinRoutes
MATCH
(overseas:Airport) -[inRoute:Route]-> (domestic:Airport),
(domestic:Airport) -[outRoute:Route]-> (overseas:Airport)
WHERE domestic.airportcountry = "Greece" AND overseas.airportcountry <> "Greece"
RETURN domestic.airportcity as City,
round(toFloat(count(outRoute))/totaloutRoutes * 100, 2) as OutboundPercentage,
round(toFloat(count(inRoute))/totalinRoutes * 100, 2) as InboundPercentage
ORDER BY OutboundPercentage DESC;

-- Query 7
MATCH (:Airport) -[route:Route]-> (dest:Airport)
WHERE dest.airportcountry = "Greece"
UNWIND route.equipment as PlaneType
WITH PlaneType, route
WHERE PlaneType = "738" OR PlaneType = "320"
RETURN PlaneType, count(route) as Flights
ORDER BY Flights;

-- Query 8 
MATCH (src:Airport) - [r:Route] -> (sss:Airport)
SET src.airportlatitude = toFloat(src.airportlatitude),
src.airportlongitude=toFloat(src.airportlongitude),
sss.airportlatitude= toFloat(sss.airportlatitude), sss.airportlongitude =
toFloat(sss.airportlongitude)
WITH point({ longitude: src.airportlongitude,latitude: src.airportlatitude }) AS
p1, point({ longitude: sss.airportlongitude, latitude: sss.airportlatitude
}) AS p2, src, sss
RETURN src.airportname AS From, sss.airportname AS To, point.distance(p1, p2) AS Distance
ORDER BY Distance DESC LIMIT 10;

--Query 9 
MATCH (source:Airport) -[route:Route]-> (dest:Airport)
WHERE dest.airportcity = "Berlin" AND NOT(route.stop)
WITH collect(source) as AirportsDirectlyConnectedWithBerlin
MATCH (source:Airport) -[route:Route]-> (dest:Airport)
WHERE NOT source in AirportsDirectlyConnectedWithBerlin
RETURN source.airportcity as City, count(route) as Flights
ORDER BY Flights DESC LIMIT 5;

--Query 10 
MATCH (source:Airport {
airportname: "Eleftherios Venizelos International Airport"
}),
(dest:Airport {
airportname: "Sydney Kingsford Smith International Airport"
})
RETURN source, dest, shortestPath((source)-[:Route*]-(dest))