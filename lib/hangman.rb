require 'json'

class Hangman
  def initialize
    @word = get_word 
    @board = nil
    @guessed_letters = Array.new #so order of guesses will be preserved
    @guesses = 8
    @history = load_history #could be class variable since it is shared!
    @name = nil
  end

  attr_accessor :word, :board, :guessed_letters, :guesses, :history, :name

  def self.play
    game = Hangman.new 
    puts "word is: #{game.word}" #for debugging

    game.set_initial_board

    unless game.history.empty?
      puts "Would you like to load a saved game? y/n"

      load = gets.chomp

      if load[0] == 'y'
        game_choice = nil

        until game.history.keys.include?(game_choice)
          puts "The options are: #{game.history.keys.join(", ")}" 

          game_choice = gets.chomp.downcase
        end

        game.load_game(game_choice)
      end
    end
    game.display_game_state #want to display the starting state

    game.play_game
  end

  def set_initial_board
    self.board = ''.rjust(word.length, '_')
  end

  def load_game(name)
    self.word = history[name]["word"]

    self.board = history[name]["board"]

    self.guessed_letters = history[name]["guessed_letters"]

    self.guesses = history[name]["guesses"]

    self.name = history[name]["name"]
  end

  def play_game
    while guesses > 0 && board.include?("_")
      guess = get_guess

      update_game_state(guess)

      display_game_state 

      ask_to_save
    end

    display_result
  end

  def display_game_state
    puts board

    if guessed_letters.length > 0
      puts "Guessed Letters: #{guessed_letters.join(", ")}"
    end
  end

  private

  def load_history
    if File.exists?('history.json')
      file = File.read('history.json')

      data = JSON.parse(file)
      data
    else
      Hash.new
    end
  end

  def save_game 
    #ask for name if the game doesn't have one
    if name.nil?
      puts "Please give your game a name."

      self.name = gets.chomp.downcase
    end

    self.history[name] = {
      "word" => word, "board" => board, "guessed_letters" => guessed_letters, 
      "guesses" => guesses, "name" => name
    }

    puts "to be written to file: #{history}"

    File.write('history.json', JSON.dump(history)) 
  end

  def ask_to_save
    puts "Would you like to save this game? y/n"

    save = gets.chomp

    if save[0] == 'y'
      save_game
    end
  end

  def unused_letters 
    ('a'..'z').to_a.reject { |letter| guessed_letters.include?(letter) }
  end

  def get_guess 
    guess = nil
    available = unused_letters

    puts "You have #{8 - guessed_letters.length} guesses remaining."

    loop do
      puts "To make a guess, choose an unused letter or try to guess the word."

      puts "Unused letters are: #{available}"

      guess = gets.chomp

      break if available.include?(guess) || guess.length > 1
    end
    guess
  end

  def update_game_state(guess) #need to check if guess that is word matches word
    if guess.length > 1
      check_word_guess(guess)
    else
      check_letter_guess(guess)
    end
  end

  def check_word_guess(guess)
    if guess == word
      self.board = word
    else
      self.guesses -= 1
    end
  end

  def check_letter_guess(guess)
    if word.include?(guess)
      update_board(guess)
    else
      guessed_letters.push(guess)
      self.guesses -= 1
    end
  end

  def update_board(guess)
    positions = Array.new

    word.each_char.with_index do |char, index|
      if char == guess
        positions.push(index)
      end
    end
    
    positions.each { |i| self.board[i] = guess }
  end

  def display_result
    if board.include?("_")
      puts "You Lost. Word was #{word}."
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
Hangman.play