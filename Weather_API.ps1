<#
                        ##  BAROMETRIC PRESSURE ##
 -Low pressure usually means it will be cloudy, rainy, or windy.Air moves away from areas of high pressure.

 -High-pressure areas usually create cool, dry air and clear skies.

 The standard barometric pressure at sea level is 29.92 inches (1,013 millibars)
 of mercury (also measured as 1 atmosphere). In general, a normal range for barometric
 pressure is between 28.5 (965 millibars) and 30.7 inches (1,040 millibars) of mercury.

 Hurricanes typically form over warm ocean waters in areas of low atmospheric pressure.
 This low pressure allows air to rise and form clouds, leading to the development of a system
 that can draw in more air, intensifying the hurricane as the pressure continues to drop
#>

<#API_KEY ######>



#####################################################################################################################
#####################################################################################################################
            ##  CURRENT WEATHER CONDITIONS BY ZIPCODE  ##

$api_key = "#####"
$current_place = "zipcode"

$uri = "http://api.weatherapi.com/v1/current.json?key=" + $api_key + "&q="+$current_place+ "&aqi=no"
$current = Invoke-RestMethod -Uri $uri
#$current

foreach ($c in $current.current){Write-Output "Current Conditions for:"
$properties = [ordered]@{Location = $current.location.name,$current.location.region
                        LastUpdated = $c.last_updated
                        Condition = $c.condition.text
                        TempNow_F = $c.temp_f
                        FeelsLike_F = $c.feelslike_f
                        Pressure_in = $c.pressure_in
                        Humidity = $c.humidity
                        WindDirection = $c.wind_dir
                        WindSpeed_mph = $c.wind_mph
                        WindGust_mph = $c.gust_mph
                        WindChill = $c.windchill_f
                        Cloud = $c.cloud
                        Visibility_miles = $c.vis_miles
                        Precipitation_in = $c.precip_in
                        HeatIndex_F = $c.heatindex_f
                        LocalTime = $current.location.localtime}
$obj = New-Object -TypeName PSObject -Property $properties
Write-Output $obj}
#####################################################################################################################
#####################################################################################################################
#####################################################################################################################
#####################################################################################################################
#####################################################################################################################
                    ##   WEATHER FORECAST BY ZIPCODE and UP TO 10 DAYS ##
$api_key = '#####'
$place = "zipcode"
$days = "5"

$uriF = "http://api.weatherapi.com/v1/forecast.json?key="+ $api_key + "&q=" + $place + "&days=" + $days + "&aqi=no&alerts=no"
$forcast = Invoke-RestMethod -uri $uriF
#$forcast.location.name

foreach ($i in $forcast.forecast.forecastday){
$properties = [ordered]@{Date = $i.date
                        Location = $forcast.location.name,$forcast.location.region
                        Condition = $i.day.condition.text
                        MaxTemp = $i.day.maxtemp_f
                        MinTemp = $i.day.mintemp_f
                        MaxWind = $i.day.maxwind_mph
                        Humidity = $i.day.avghumidity
                        ChanceRain = $i.day.daily_chance_of_rain
                        Will_it_Rain = $i.day.daily_will_it_rain
                        ChanceSnow = $i.day.daily_chance_of_snow
                        TotalPrecip = $i.day.totalprecip_mm
                        Sunrise = $i.astro.sunrise
                        Sunset = $i.astro.sunset}
$obj_f = New-Object -TypeName PSObject -Property $properties
Write-Output $obj_f}
#####################################################################################################################
#####################################################################################################################
                                 ##   WEATHER ALERTS BY ZIPCODE and UP TO 10 DAYS ##
#http://api.weatherapi.com/v1/forecast.json?key=#####&q=77005&days=5&aqi=no&alerts=yes

$api_key = '####'
$place = "sugar%20land"
$days = "5"

$uri_a = "http://api.weatherapi.com/v1/forecast.json?key=" + $api_key + "&q="+ $place +"&days=" + $days +"&aqi=no&alerts=yes"
$forcast_a = Invoke-RestMethod -uri $uri_a
#$forcast_a

foreach ($alert in $forcast_a.alerts.alert){
$properties = [ordered]@{Location = $forcast_a.location.name,$forcast_a.location.region
                         Headline = $alert.headline
                         Event = $alert.event
                         Effective = $alert.effective
                         Expires = $alert.expires
                         Description = $alert.desc
                         Category = $alert.category
                         Certainty = $alert.certainty
                         Special_Instructions = $alert.instruction}
                         Write-Output 'Alerts'
$obj_alert = New-Object -TypeName PSObject -Property $properties
Write-Output $obj_alert}
#####################################################################################################################
#####################################################################################################################
#http://api.weatherapi.com/v1/sports.json?key=####&q=64114
                                     ##   FOOTBALL EVENTS BY ZIPCODE ##

$api_key = '#####'
$place = "77005"


$uri_sports = "http://api.weatherapi.com/v1/sports.json?key="+ $api_key + "&q=" + $place
$sport = Invoke-RestMethod -uri $uri_sports
#$sport

foreach ($s in $sport.football){
$properties = [ordered]@{Game = $s.match
                         Stadium = $s.stadium
                         Tournament = $s.tournament
                         Starttime = $s.start
                         Country = $s.country
                         Region = $s.region}
$obj_sport = New-Object -TypeName PSObject -Property $properties
Write-Output $obj_sport}
#####################################################################################################################
#####################################################################################################################

