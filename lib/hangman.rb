require 'json'

class Hangman
  def initialize
    @word = get_word 
    @board = nil
    @guessed_letters = Array.new #so order of guesses will be preserved
    @history = load_history
    @name = nil
  end

  attr_accessor :word, :board, :guessed_letters, :history, :name 

  def self.play
    game = Hangman.new 

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
    game.display_game_state #display the starting state

    game.play_game
  end

  def set_initial_board
    self.board = ''.rjust(word.length, '_')
  end

  def load_game(name)
    self.word = history[name]["word"]

    self.board = history[name]["board"]

    self.guessed_letters = history[name]["guessed_letters"]

    self.name = history[name]["name"]
  end

  def play_game
    while guessed_letters.length < 8
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
    #ask for name if the game doesn't have one, lowercase it
    if name.nil?
      puts "Please give your game a name."

      self.name = gets.chomp.downcase
    end
    #add game to history, then write history to file
    self.history[name] = {
      "word" => word, "board" => board, "guessed_letters" => guessed_letters, 
      "name" => name
    }

    puts "to be written to file: #{history}"

    File.write('history.json', JSON.dump(history)) #did not work
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
    loop do
      puts "Guess a letter."

      puts "Unused letters are: #{available}"

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
Hangman.play