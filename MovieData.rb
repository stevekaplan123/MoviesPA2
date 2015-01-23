#!/usr/bin/ruby
require 'pry'

class MovieTest

##found std dev code in
#book "The Ruby Way"

	attr_reader :avg
	attr_reader :std_dev 
	attr_reader :root_mean_square_error
	attr_reader :results

	def initialize(array)
		@results = array
	end

	def rms
		#pythagorean theorem sqrt(a^2 + b^2) using the mean and standard deviation as a and b
		@root_mean_square_error = Math.sqrt((@avg ** 2)+(@std_dev ** 2))
		@root_mean_square_error
	end

	def to_a
		#returns array of the values only of each hash of results 
		#originally each element in the array results read something like User=>1, Movie=>10, Rating=3, Prediciton=>3.5
		#now each element in array_results reads like [1, 10, 3, 3.5]
		array_results = []
		@results.each { |result| 
			temp_array = result.values
			array_results.push(temp_array)
		}
		array_results
	end

	def mean(array)
		#finds the mean error by summing the difference between the prediction and actual rating 
		#and then divides by the total
		sum = 0.to_f
	 	array.each { |hash|
	 		value = (hash["Prediction"].to_f-hash["Rating"].to_i).abs
	 		sum += value 
	 	}
	 	@avg = sum.to_f/array.size.to_f
	 	@avg
	end

	def standard_deviation(array=@results)
		#finds std_dev by using a formula I found online for std_dev
 	 	m = mean(array)
 	 	variance = 0

 	 	array.each { |hash|
 	 		value = (hash["Prediction"].to_f-hash["Rating"].to_f).abs
 	 		variance += (value - m) ** 2
 	 	}
  		@std_dev = Math.sqrt(variance/array.size)
  		@std_dev
	end

end

class MovieData
	attr_reader :users
	attr_reader :movies
	attr_reader :movies_average_rating
	attr_reader :test_users
	attr_reader :test_movies
	attr_reader :test_movies_average_rating
	attr_reader :num_users
	attr_reader :num_movies
	attr_reader :test_num_users
	attr_reader :test_num_movies
		
	def initialize(directory, filename=:u)
	  @users=Hash.new
	  @movies=Hash.new
	  @movies_average_rating = Hash.new
	  @test = Array.new	  
	  numLines=0
	  
	  Dir.chdir(Dir.pwd+"/"+directory)
	  
	  if filename == :u
	  		filename = "u.data"
	  		load_data(filename)
	  else
	  		training = filename.to_s+".base"
	  		test = filename.to_s+".test"
	  		load_data(training)
	  		load_data_test(test)
	  end
	 
   end
   
   def load_data_test(filename)
   	 count = 0
   	 IO.foreach(filename) { |line| 
		ids = line.split("\t")
		curr_user = ids[0]
		curr_movie = ids[1]
		curr_rating = ids[2]
		@test[count] = {"User"=>curr_user, "Movie"=>curr_movie, "Rating"=>curr_rating}
		count += 1
	}
   end
   
   def load_data(filename)
	 IO.foreach(filename) { |line| 
		ids = line.split("\t")
		curr_user = ids[0]
		curr_movie = ids[1]
		curr_rating = ids[2]
		if @users.has_key?(curr_user) == true
			@users[curr_user][curr_movie] = curr_rating
		else
			@users[curr_user] = {curr_movie => curr_rating}
		end
	
		if @movies.has_key?(curr_movie)==true
			rating, count = @movies[curr_movie].split("=")
			total = rating.to_i + curr_rating.to_i
			count=count.to_i+1
			@movies[curr_movie] = total.to_s + "=" +count.to_s
		else
			@movies[curr_movie] = curr_rating + "=1"
		end
	 }
		
	  @movies.each_key { |movieKey|
	  	rating, count = @movies[movieKey].split("=")
		if count.to_i != 0
			amt = rating.to_f/count.to_f
			@movies_average_rating[movieKey] = amt
		else
			@movies_average_rating[movieKey] = -1
		end
		
	  }
	  @num_users = @users.length
	  @num_movies = @movies.length
	  
	end
	
	def validUser(user)
	  if user.to_i <= 0 or user.to_i > @num_users
      		puts "Invalid number for user.  Must be between 1 and "+@num_users.to_s
      		return false
      end
      return true
    end
    
    def validMovie(movie)
      if movie.to_i <= 0 or movie.to_i > @num_movies
      		puts "Invalid number for movie.  Must be between 1 and "+@num_movies.to_s
      		return false
      end
      return true
    end
    
    def movies(user)
    	#returns an array of the keys of the hash for the given user
    	user = user.to_s
    	if validUser(user) 
    		 @users[user].keys
    	end
    end
    
    def rating(user, movie)
    	#returns the rating of given user of given movie
    	#or returns 0 if the user didn't rate that movie
    	user = user.to_s
    	movie = movie.to_s
    	if validUser(user) and validMovie(movie)
    		if (@users[user].has_key?movie)==true
    			@users[user][movie]
    		else
    			0
    		end
    	end
    end
    
    def viewers(movie)
    	#returns an array of all users who have watched the given movie
    	movie = movie.to_s
    	viewers = []
    	@users.keys.each { |user| 
    		if (@users[user].has_key?movie)==true
    			viewers.push(user)
    		end
    	}
    	return viewers
    end
    
 	def predict(user, movie)
 		#calculates a predicition by averaging two values together
 		#one value is the average rating given to the movie by all users who watched it
 		#and the other value is the average rating the user gave to all movies that user watched

 		user = user.to_s
 		movie = movie.to_s
 		if ((validUser(user)==false or validMovie(movie)==false))
 			-1
 		end

 		avg_rating_user = 0
 		avg_rating_movie = 0


 		#first calculate the average rating that the given user gives to his/her movies
 		total = 0
 		movies_watched = movies(user)
 		movies_watched.each { |temp_movie|
 			total += @users[user][temp_movie].to_i
 		}

 		if movies_watched.length == 0
 			avg_rating_user = 0
 		else
	 		avg_rating_user = total.to_f/(movies_watched.length).to_f
	 	end

 		total = 0

 		#now calculate the average rating given to this movie by all users who have seen it
 		viewers_of_movie = viewers(movie)
 		viewers_of_movie.each { |temp_user|
 			total += @users[temp_user][movie].to_i
 		}
 
 		
 		if viewers_of_movie.length==0
 			avg_rating_movie = 0
 		else
 			avg_rating_movie = total.to_f/(viewers_of_movie.length).to_f
 		end

 		(avg_rating_movie + avg_rating_user)/(2.to_f)
 	end   

 	def run_test(iterations=-1)
 	#any given iterations over 0 will lead to that amount of iterations being used for the test
 	#iterations less than 0 is an error and the entire test array is iterated over instead
 	#also, passing no value to function leads to entire test array being iterated over

 		count = 0
 		@results = []

 		if iterations <= -1
 			iterations = @test.size
 		end


 		@test.each { |hash| 
 			if count == iterations
 				break
 			end
 			curr_user = hash["User"]
 			curr_movie = hash["Movie"]
 			curr_rating = hash["Rating"]

 			curr_user = curr_user.to_i 
 			curr_movie = curr_movie.to_i 
 			curr_rating = curr_rating.to_i

 			prediction = predict(curr_user, curr_movie)

 			@results[count] = {"User"=>curr_user, "Movie"=>curr_movie, "Rating"=>curr_rating, "Prediction"=>prediction}
 			count += 1
 		}
 		tester = MovieTest.new(@results)
 		tester.standard_deviation(@results)
 		tester.rms

 		puts "Average error: "+tester.avg.to_s  
 		puts "Standard deviation: "+tester.std_dev.to_s
 		puts "Root mean square errpr: "+tester.root_mean_square_error.to_s
 		puts tester.to_a
 	end
end

movieDataObj = MovieData.new("ml-100k", :u1)


puts movieDataObj.run_test
