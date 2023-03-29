require 'json'
require 'time'

class Hangman
  def initialize
    @word = get_word 
    @board = nil
    @guessed_letters = Array.new #so order of guesses will be preserved
    @guesses = 8
    @history = load_history 
    @name = nil
  end

  attr_accessor :word, :board, :guessed_letters, :guesses, :history, :name

  def self.play
    game = Hangman.new 

    game.set_initial_board

    unfinished = game.get_unfinished_games

    unless unfinished.empty?
      loop do
        puts "Would you like to load a saved game? y/n"

        load = gets.chomp.downcase

        if load == 'y' || load == 'yes'
          game_choice = nil

          until unfinished.include?(game_choice)
            puts "The options are: #{unfinished.keys.join(", ")}" 

            game_choice = gets.chomp.downcase
          end

          game.load_game(game_choice)
          break

        elsif load == 'n' || load == 'no'
          break
        end
      end
    end

    game.display_game_state 

    game.play_game
  end

  def set_initial_board
    self.board = ''.rjust(word.length, '_')
  end

  def load_game(input_name)
    self.word = history[input_name]["word"]

    self.board = history[input_name]["board"]

    self.guessed_letters = history[input_name]["guessed_letters"]

    self.guesses = history[input_name]["guesses"]

    self.name = input_name
  end

  def play_game
    while guesses > 0 && board.include?("_")
      guess = get_guess

      won = update_game_state(guess)

      display_game_state 

      break if won

      ask_to_save
    end

    display_result
    save_game(false) 
  end

  def display_game_state
    puts board

    if guessed_letters.length > 0
      puts "Guessed Letters: #{guessed_letters.join(", ")}"
    end
  end

  def get_unfinished_games
    unfinished = history.select { |k, v| v["board"].include?("_") }
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

  def save_game(ongoing = true) 
    if name.nil? && ongoing
      puts "Please give your game a name."

      self.name = gets.chomp.downcase

    elsif name.nil? #save finished, but previously unsaved games to history - in the event we want to add prizes or something
      self.name = Time.now.strftime('%s')
    end

    self.history[name] = {
      "word" => word, "board" => board, "guessed_letters" => guessed_letters, 
      "guesses" => guesses
    }

    File.write('history.json', JSON.dump(history)) 
  end

  def ask_to_save
    loop do
      puts "Would you like to save this game? y/n"

      save = gets.chomp.downcase

      if save == 'y' || save == 'yes'
        save_game
        break
      elsif save =='n' || save == 'no'
        break
      end
    end
  end

  def unused_letters 
    ('a'..'z').to_a.reject { |letter| guessed_letters.include?(letter) }
  end

  def get_guess 
    guess = nil
    available = unused_letters

    puts "You have #{guesses} guesses remaining."

    loop do
      puts "To make a guess, choose an unused letter or try to guess the word."

      puts "Unused letters are: #{available}"

      guess = gets.chomp

      break if available.include?(guess) || guess.length > 1
    end
    guess
  end

  def update_game_state(guess)
    won = guess.length > 1 ? check_word_guess(guess) : check_letter_guess(guess)
  end

  def check_word_guess(guess)
    if guess == word
      self.board = word
      true
    else
      self.guesses -= 1
      false
    end
  end

  def check_letter_guess(guess)
    if word.include?(guess)
      update_board(guess) 
      won = board.include?("_") ? false : true
      return won
    else
      guessed_letters.push(guess)
      self.guesses -= 1
    end
    false
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