require 'json'

class DataStore
  attr_accessor :path

  def initialize(path = 'store/store.json')
    begin
      File.open(path, 'w') unless File.exist?(path)
      @file = path
    rescue StandardError => e
      puts e.message
    end
  end

  def create(key, json, ttl = nil)
    begin
     @store = File.read(@file)
     data_hash = @store.match(/\A\s*\Z/) ? {} : JSON.parse(@store)
     raise 'Key already present' if data_hash.key?(key)
     raise 'Invalid JSON' unless json.is_a?(Hash)

     json[:ttl] = Time.now.to_i + ttl
     data_hash[key] = json
     File.write(@file, JSON.dump(data_hash))
     puts "Successfully Added #{json}"
   rescue StandardError => e
     puts e.message
   end
 end

  def delete(key)
    begin
      @store = File.read(@file)
      data_hash = JSON.parse(@store)
      puts data_hash
      raise 'Invalid Key' unless data_hash.key?(key)
      if data_hash[key]['ttl']
        raise 'Value Expired' if data_hash[key]['ttl'].to_i < Time.now.to_i
      end
      data_hash.delete(key)
      File.write(@file, JSON.dump(data_hash))
      p 'Key has been deleted'
    rescue => e
      puts e.message
    end
  end

  def read(key)
    begin
      @store = File.read(@file)
      data_hash = JSON.parse(@store)
      raise 'Invalid Key' unless data_hash.key?(key)
      if data_hash[key]['ttl']
        raise 'Value Expired' if data_hash[key]['ttl'].to_i < Time.now.to_i
      end
      data_hash[key]
    rescue StandardError => e
      puts e.message
    end
  end
end
