class TravelingSalesman

  def nearest_neighbor(city, availableCities, distances)
    nearestCity = availableCities[0]

    availableCities.each do |aCity|
      nearestCity = aCity if distances[city][aCity] < distances[city][nearestCity]
    end
    nearestCity
  end

  def generate_distances(coordinates)
    distances = Array.new(coordinates.length) { Array.new(coordinates.length, 0) }

    coordinates.each_index do |first|
      x1 = coordinates[first][0]
      y1 = coordinates[first][1]

      distances[first].each_index do |second|
        x2 = coordinates[second][0]
        y2 = coordinates[second][1]

        if distances[first][second] == 0
          distance = Math.sqrt((x2-x1)**2+(y2-y1)**2)
          distances[first][second] = distance
          distances[second][first] = distance
        end
      end
    end

    ##### print distances #####
    # distances.each_index do |i| #ddd
    #   distances[i].each_index do |j|
    #     print distances[i][j].round(2).to_s + "\t"
    #   end
    #   puts ""
    # end

    distances
  end

  def generate_random_cities(n)
    cities = []

    n.times do
      cities.push([ rand(20), rand(20) ])
    end
    cities
  end

  def get_coordinates(n)
    coordinates = []

    n.times do |i|
      puts "\n#{i+1} city"
      print "x: "
      x = gets.chomp.to_i
      print "y: "
      y = gets.chomp.to_i

      coordinates.push([ x, y ])
    end
    coordinates
  end

  def nearest_neighbor_solution(firstCity, distances)
    availableCities = [ *0..distances.length-1 ]
    availableCities.delete(firstCity-1)
    route = [firstCity-1]
    lastCity = firstCity-1

    availableCities.length.times do
      city = nearest_neighbor(lastCity, availableCities, distances)
      route.push(city)
      lastCity = city
      availableCities.delete(city)
    end
    route.push(firstCity-1)
    route.map!{ |i| i + 1 }
  end

  def total_route(route, distances)
    sum = 0
    route = route.map { |i| i - 1 }
    (route.length - 1).times do |i|
      sum += distances[route[i]][route[i+1]]
    end
    sum
  end
end

print "How many cities? "
n = gets.chomp.to_i

instance = TravelingSalesman.new
coor = instance.get_coordinates(n)
dist = instance.generate_distances(coor)
print "\nCity begin? "
first = gets.chomp.to_i
r = instance.nearest_neighbor_solution(first,dist)
total = instance.total_route(r, dist)
puts "\nDistance: #{total}"
puts "Route: #{r}"
