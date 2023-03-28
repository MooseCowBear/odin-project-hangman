def load_words
  words = File.read('google-10000-english-no-swears.txt').split
end

def get_word(words)
  words.map { |word| word if word.length >= 5 && word.length <= 7 }.compact.sample
end

puts "Welcome to Hangman"

words = load_words
word = get_word(words)
pp word

