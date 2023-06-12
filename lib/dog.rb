class Dog
    attr_accessor :id, :name, :breed
  
    def initialize(id: nil, name:, breed:)
      @id = id
      @name = name
      @breed = breed
    end
  
    def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
      SQL
      DB[:conn].execute(sql)
    end
  
    def self.drop_table
      sql = "DROP TABLE IF EXISTS dogs"
      DB[:conn].execute(sql)
    end
  
    def save
      if id.nil?
        insert
      else
        update
      end
      self
    end
  
    def self.create(name:, breed:)
      dog = Dog.new(name: name, breed: breed)
      dog.save
    end
  
    def self.new_from_db(row)
      id, name, breed = row
      Dog.new(id: id, name: name, breed: breed)
    end
  
    def self.all
      sql = "SELECT * FROM dogs"
      result = DB[:conn].execute(sql)
      result.map { |row| new_from_db(row) }
    end
  
    def self.find_by_name(name)
      sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
      result = DB[:conn].execute(sql, name)
      result.empty? ? nil : new_from_db(result[0])
    end
  
    def self.find(id)
      sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
      result = DB[:conn].execute(sql, id)
      result.empty? ? nil : new_from_db(result[0])
    end
  
    # Bonus methods
  
    def self.find_or_create_by(name:, breed:)
      dog = find_by_name(name)
      return dog unless dog.nil?
  
      create(name: name, breed: breed)
    end
  
    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, name, breed, id)
    end
  
    private
  
    def insert
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    end
  end
  
