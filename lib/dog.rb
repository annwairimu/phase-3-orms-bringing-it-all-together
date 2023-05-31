class Dog
    attr_accessor :id, :name, :breed
  
    def initialize(attributes)
      @id = attributes[:id]
      @name = attributes[:name]
      @breed = attributes[:breed]
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
      if self.id
        self.update
      else
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end
  
    def self.create(attributes)
      dog = self.new(attributes)
      dog.save
    end
  
    def self.new_from_db(row)
      attributes = {
        id: row[0],
        name: row[1],
        breed: row[2]
      }
      self.new(attributes)
    end
  
    def self.all
      sql = "SELECT * FROM dogs"
      result = DB[:conn].execute(sql)
      result.map { |row| self.new_from_db(row) }
    end
  
    def self.find_by_name(name)
      sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
      result = DB[:conn].execute(sql, name)
      self.new_from_db(result[0]) unless result.empty?
    end
  
    def self.find(id)
      sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
      result = DB[:conn].execute(sql, id)
      self.new_from_db(result[0]) unless result.empty?
    end
  
  end
  
