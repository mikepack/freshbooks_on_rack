require 'ruby-freshbooks'

class FBOnRack
  @cachable_entities = ['staff', 'task']

  def initialize
    @connections = [FreshBooks::Client.new('account1.freshbooks.com', 'apitoken1'),
                    FreshBooks::Client.new('account2.freshbooks.com', 'apitoken2')]
  end

  def call(env)
    res = Rack::Response.new
    res.write "<title>FreshBooks on Rack</title>"

    @connections.each do |connection|
      connection.project.list['projects']['project'].each do |project|
        res.write "<h1>Project: #{project['name']}</h1>"
        total_income = 0.0
        total_hours = 0.0

        connection.time_entry.list(:project_id => project['project_id'])['time_entries']['time_entry'].each do |entry|
          rate = get_rate(connection, project, entry)
          total_hours += entry['hours'].to_f
          total_income += rate.to_f * entry['hours'].to_f
        end
        res.write "Total hours: #{total_hours}<br />"
        res.write "Total income: #{total_income}<br />"
      end
    end

    res.finish
  end

private

  @cachable_entities.each do |entity_name|
    cache_var = instance_variable_set("@#{entity_name}_cache", {})
    get_entity = lambda do |connection, entity_id|
      if cache_var.has_key?(entity_id) # Check if the entity is already cached
        cache_var[entity_id]
      else
        entity = connection.send(entity_name).get(("#{entity_name}_id").to_sym => entity_id)[entity_name] # Make the API call for whatever entity
        cache_var[entity_id] = entity # Cache the API call
      end
    end
    define_method(("get_#{entity_name}").to_sym, get_entity)
  end

  def get_rate(connection, project, entry)
    case project['bill_method']
    when 'project-rate'
      project['rate']
    when 'staff-rate'
      get_staff(connection, entry['staff_id'])['rate']
    when 'task-rate'
      get_task(connection, entry['task_id'])['rate']
    end
  end
end