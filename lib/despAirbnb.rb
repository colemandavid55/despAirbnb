require_relative 'geo/geocalc'

module DespAirbnb
  
  def self.build_dummy_rooms
    File.readlines(File.expand_path File.dirname(__FILE__) + "/dummyData/results.log").first
  end

  def self.get_dummy_rooms
    rooms = JSON.parse(build_dummy_rooms)
    rooms.map do |room|  
      {
        id: room['id'].to_i,
        latitude: room['latitude'],
        longitude: room['longitude']
      }
    end
  end

  def self.get_dummy_room(room_id)
    rooms = JSON.parse(build_dummy_rooms)
    idx = rooms.index { |r| r['id'].to_i == room_id } 
    {
      id: rooms[idx]['id'].to_i,
      name: rooms[idx]['name'],
      price: rooms[idx]['price'],
      location: rooms[idx]['location'],
      latitude: rooms[idx]['latitude'],
      longitude: rooms[idx]['longitude'],
      roomUrl: rooms[idx]['roomUrl'],
      imgUrl: rooms[idx]['imgUrl']
    }

  end

  def self.get_rooms(rooms)
    rooms.map do |room|  
      {
        id: room['id'].to_i,
        latitude: room['latitude'],
        longitude: room['longitude']
      }
    end
  end

  def self.get_room(rooms, room_id)
    idx = rooms.index { |r| r['id'].to_i == room_id } 
    {
      id: rooms[idx]['id'].to_i,
      name: rooms[idx]['name'],
      price: rooms[idx]['price'],
      location: rooms[idx]['location'],
      latitude: rooms[idx]['latitude'],
      longitude: rooms[idx]['longitude'],
      roomUrl: rooms[idx]['roomUrl'],
      imgUrl: rooms[idx]['imgUrl']
    }

  end

end
