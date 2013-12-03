class Trip < ActiveRecord::Base
  belongs_to :origin
  belongs_to :destination

  def start_time(seconds = 5.minutes)
    @time = self.origin.created_at
    Time.at((@time.to_f / seconds).round * seconds)
  end

  def origin_stations
    Station.near([self.origin.latitude, self.origin.longitude], 0.25)
  end

  def destination_stations
    Station.near([self.destination.latitude, self.destination.longitude], 0.25)
  end


  def origin_bike_status
    uri = URI.parse('http://citibikenyc.com/stations/json')
    json = uri.read
    hash = JSON.parse(json)
    array = hash["stationBeanList"]
    bikes =[]
   
    origin_stations.collect do |station|
      array.each do |live_station|
        if live_station["id"] == station.station_id #) & (live_station["availableBikes"]!=nil)
          bikes << live_station["availableBikes"]
        end
      end 
    end
    bikes
  end

  def destination_rack_status
    uri = URI.parse('http://citibikenyc.com/stations/json')
    json = uri.read
    hash = JSON.parse(json)
    array = hash["stationBeanList"]
    racks =[]
   
    destination_stations.collect do |station|
      array.each do |live_station|
        if live_station["id"] == station.station_id 
          racks << live_station["availableDocks"]
        end
      end 
    end
    racks
  end

  def rollback(roll_days, roll_minutes)
       start_time - roll_days.days + roll_minutes.minutes
  end

  def origin_history(min)
    origin_stations.collect do |station| 
      cmd= "SELECT * FROM station_#{station.station_id} WHERE station_time = \'#{rollback(70, min).to_s[0..18]}\'"
      connection.execute(cmd).field_values("bikes").join
    end
  end

  def destination_history(min)
    destination_stations.collect do |station| 
      cmd= "SELECT * FROM station_#{station.station_id} WHERE station_time = \'#{rollback(70,min).to_s[0..18]}\'"
      connection.execute(cmd).field_values("free").join
    end
  end 

end



