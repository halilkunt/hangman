def start_game
  puts "Would you like the start a new game or continue the last saved game. Press 'n' for new,
    press 's' for saved game"
  choice = gets.chomp.downcase

  if choice == "n"
    Game.new
  else
    File.open('game') do |f|  
      Marshal.load(f)  
    end
  end 
end

def choose_random_word
  file = File.open("5desk.txt", "r")

  word_array = file.read.split("\r\n")

  random_word = word_array.sample

  until random_word.length < 13 && random_word.length > 5
  random_word = word_array.sample
  end

  random_word
end

class Game
  attr_accessor :right_word, :wrong_word, :secret_word, :show_word_progress, :counter
  
  def initialize(right_word = [], wrong_word = [], secret_word = choose_random_word, counter = 20)
    @right_word = right_word
    @wrong_word = wrong_word
    @secret_word = secret_word.downcase
    @show_word_progress = secret_word.downcase.split("").map{ |value| value = "_"}
    @counter = counter
  end

  def check_win
    unless self.show_word_progress.include?("_")
      true
    else
      false
    end
  end

  def show_status(array, word = "")
    if array == self.right_word
      self.secret_word.split("").each_with_index do |value, index|
        if value == word
          self.show_word_progress[index] = value
        end
      end
    end
    puts self.show_word_progress.join(" ")

    if check_win
      puts "Congrats you won the game"
    else
     puts "Your right guesses are '#{self.right_word.join(" ")}'"
     puts "Your wrong guesses are '#{self.wrong_word.join(" ")}'"
     puts "Your have #{20 - self.right_word.length - self.wrong_word.length} remaining right"
     puts "If you want to save and quit the game enter 'sa'"
    end
  end

  def add_word(right_or_wrong_array, word)
    right_or_wrong_array.push word
    if right_or_wrong_array == self.right_word
      show_status(right_or_wrong_array, word)
    else
      show_status(right_or_wrong_array)
    end
  end

  def check(word)
    self.counter -= 1
    if self.secret_word.include? word
      add_word(self.right_word, word)
    else 
      add_word(self.wrong_word, word)
    end
  end
end

def play
  game = start_game

  game.counter.times do |index|
    puts "Please enter your word guess"
    guess = gets.chomp.downcase
    if guess == "sa"
      File.open('game', 'w+') do |f|  
        Marshal.dump(game, f)  
      end 
      break
    end
    game.check(guess)
    if game.check_win
      break
    elsif index == 19
      puts "You run out of guess. Please try again"
      puts "The word you were tring to guess was: #{game.secret_word}"
    end
  end
end


play