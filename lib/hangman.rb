require 'json'



class Hangman
  def initialize
    @word = get_word 
    @board = nil
    @guessed_letters = Array.new #so order of guesses will be preserved
  end

  attr_accessor :word, :board, :guessed_letters #will move later

  #serializing, deserializing - this is for only one game!
  def to_json 
    JSON.dump ({
      :word => @word,
      :board => @board,
      :guessed_letters => @guessed_letters
    })
  end

  def self.from_json(string)
    data = JSON.load string
    self.new(data['word'], data['board'], data['guessed_letters']) #assumes new takes params
  end

  #the actual game
  def self.start_game
    game = Hangman.new #for new game - will need to change to load game or start new game
    game.set_initial_board
    while game.guessed_letters.length < 8
      display_game_state
      guess = get_guess
      update_game_state
    end
    #check for a win
    display_result
  end

  private 

  def set_initial_board
    self.board = ''.rjust(word.length, '_')
  end

  def unused_letters 
    ('a'..'z').to_a.reject { |letter| guessed_letters.include?(letter) }
  end

  def get_guess 
    guess = nil
    available = unused_letters
    loop do
      puts "Guess a letter. Unused letters are: #{available}"
      guess = gets.chomp
      break if available.include?(guess)
    end
    guess
  end

  def update_game_state(guess)
    if word.include?(guess)
      update_board(guess)
    else
      guessed_letters.push(guess)
    end
  end

  def update_board(guess)
    positions = Array.new
    word.each_char.with_index do |char, index|
      if char == guess
        positions.push(index)
      end
    end
    #now have everywhere the guess letter occurs
    positions.each { |i| self.board[i] = guess }
    puts "new board state after guess #{guess}: #{board}"
  end

  def display_game_state
    puts board
    puts "Guessed Letters: #{" ".join(guessed_letters)}"
  end

  def display_result
    if board.include?("_")
      puts "You Lost. Word was #{word}"
    else
      puts "You won!"
    end
  end 

  def get_word
    words = File.read('google-10000-english-no-swears.txt').split
    words.map { |word| word if word.length >= 5 && word.length <= 7 }.compact.sample
  end
end

puts "Welcome to Hangman"



