require "pry"

class Dog
    
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER,
            name TEXT,
            breed TEXT,
            PRIMARY KEY(id)
        );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id == nil
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

            self
        else 
            self.update
            self
        end
    end

    def self.create(name:, breed:)
        row = self.new(name: name, breed: breed)
        row.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all
        sql = <<-SQL
        SELECT * FROM dogs
        SQL

        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end

    def self.find_by_name(dog_name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? LIMIT 1
        SQL

        DB[:conn].execute(sql, dog_name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_by_name_and_breed(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL

       array = DB[:conn].execute(sql, name, breed).map do |row|
            self.new_from_db(row)
        end
        array
    end
    # FAILED WHERE EXISTS ATTEMPT
    # def self.exists?(name:, breed:)
    #     sql = <<-SQL
    #     WHERE EXISTS (SELECT * FROM dogs WHERE name = ? AND breed = ?)
    #     SQL

    #    DB[:conn].execute(sql, name, breed)
    # end

    def self.find(id)
        sql= <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = self.find_by_name_and_breed(name: name, breed: breed)
        if dog.length !=0
            return dog.first
        else
            self.create(name: name, breed: breed)
        end
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end

# binding.pry
