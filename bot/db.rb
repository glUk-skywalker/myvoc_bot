# frozen_string_literal: true

class Words
  DBFILE_PATH = '/data/my-database.db'
  SEEDS_PATH = '/data/words.csv'
  TABLE_NAME = :words

  def initialize(db_path = nil)
    @db = Sequel.sqlite(db_path || DBFILE_PATH, integer_booleans: true)

    create_table! unless table_exists?

    @words = @db[TABLE_NAME]

    seed! unless @words.count.positive?
  end

  def count
    @words.count
  end

  def active
    @words.where(active: true)
  end

  def reset!
    @words.update(active: true)
  end

  def pick!
    reset! unless active.any?
    id = active.all.sample[:id]
    item = @words.where(id: id)
    item.update(active: false)
    item
  end

  def add_word(word)
    @words.insert(word: word, active: 1)
  end

  def presents?(word)
    @words.where(word: word).any?
  end

  def table_exists?
    @db.table_exists?(TABLE_NAME)
  end

  def seed!
    return unless File.exist?(SEEDS_PATH)

    CSV.read(SEEDS_PATH).each do |item_data|
      @words.insert(word: item_data[0], active: 1)
    end
  end

  def to_csv(filename)
    CSV.open(filename, 'w') do |csv|
      @words.uniq { |w| w[:word] }.each do |item|
        csv << [
          item[:word].downcase,
          item[:active],
          item[:data]
        ]
      end
    end
  end

  def uniq!
    @db.run "DELETE FROM #{TABLE_NAME} WHERE id NOT IN (SELECT min(id) FROM #{TABLE_NAME} GROUP BY word);"
  end

  private

  def create_table!
    @db.create_table TABLE_NAME do
      primary_key :id
      string :word
      boolean :active
      string :data
    end
  end
end
