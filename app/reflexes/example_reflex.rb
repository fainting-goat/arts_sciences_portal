# frozen_string_literal: true

class ExampleReflex < ApplicationReflex
  # Add Reflex methods in this file.
  #
  # All Reflex instances expose the following properties:
  #
  #   - connection - the ActionCable connection
  #   - channel - the ActionCable channel
  #   - request - an ActionDispatch::Request proxy for the socket connection
  #   - session - the ActionDispatch::Session store for the current visitor
  #   - url - the URL of the page that triggered the reflex
  #   - element - a Hash like object that represents the HTML element that triggered the reflex
  #
  # Example:
  #
  #   def example(argument=true)
  #     # Your logic here...
  #     # Any declared instance variables will be made available to the Rails controller and view.
  #   end
  #
  # Learn more at: https://docs.stimulusreflex.com

  def increment
    @count = element.dataset[:count].to_i + element.dataset[:step].to_i
  end

  def work
    entry = element.dataset[:entry]
    timeslot = element.dataset[:timeslot]

    people = UserEntry.where(entry_id: entry).pluck(:user_id)

    # create the new assignment
    assignments = Rails.cache.fetch("assignments")

    people.each do |person|
      timeslot_entry = {entry: entry, timeslot: timeslot, as: 'entrant'}
      if assignments.has_key?(person.to_s)
        assignments[person.to_s].delete_if { |x| x[:entry] == entry && x[:as] == 'entrant' }
        assignments[person.to_s].push(timeslot_entry)
      else
        assignments[person.to_s] = [timeslot_entry]
      end
    end

    judge_entry = {entry: entry, timeslot: timeslot, as: 'judge'}

    assignments.each do |key, person|
      if person.any? { |x| x[:entry] == entry && x[:as] == 'judge' }
        person.delete_if { |x| x[:entry] == entry && x[:as] == 'judge' }
        person.push(judge_entry)
      end
    end

    Rails.cache.write("assignments", assignments)

    # update which entries are assigned to which timeslot
    selected = Rails.cache.fetch("selected")

    selected[entry] = timeslot

    Rails.cache.write("selected", selected)
  end

  def judges
    entry = element.dataset[:entry]
    entrant = element.dataset[:entrant]

    assignments = Rails.cache.fetch("assignments")

    # check to see if they're already assigned to a timeslot via the entry and add that if so
    entry_timeslots = Rails.cache.fetch("selected")
    timeslot = entry_timeslots[entry]

    # if we get nil, add them with a nil timeslot and update it later
    timeslot_entry = {entry: entry, timeslot: timeslot, as: 'judge'}

    if assignments.has_key?(entrant)
      if assignments[entrant].include?(timeslot_entry)
        assignments[entrant].delete_if { |x| x[:entry] == entry && x[:as] == 'judge' }
        assignments.delete(entrant) if assignments[entrant].empty?
      else
        assignments[entrant].push(timeslot_entry)
      end
    else
      assignments[entrant] = [timeslot_entry]
    end

    Rails.cache.write("assignments", assignments)

    # update which entries are assigned to which timeslot
    judges = Rails.cache.fetch("judges")

    judges[entry] ||= []
    judges[entry].include?(entrant) ? judges[entry].delete(entrant) : judges[entry].push(entrant)

    Rails.cache.write("judges", judges)
  end

  def reset
    fair = element.dataset[:fair]

    selected = {}
    Entry.fair_entries(fair).each { |x| selected[x.id.to_s] = x.timeslot_id.to_s unless x.timeslot_id.nil? }

    judges = {}
    JudgeAssign.for_fair(fair).each do |x|
      if judges.has_key?(x.entry_id.to_s)
        judges[x.entry_id.to_s].push(x.user_id.to_s)
      else
        judges[x.entry_id.to_s] = [x.user_id.to_s]
      end
    end

    assignments = {}

    selected.each do |entry, timeslot|
      people = UserEntry.where(entry_id: entry).pluck(:user_id)
      people.each do |person|
        timeslot_entry = {entry: entry, timeslot: timeslot, as: 'entrant'}

        if assignments.has_key?(person.to_s)
          assignments[person.to_s].push(timeslot_entry)
        else
          assignments[person.to_s] = [timeslot_entry]
        end
      end

      unless judges[entry].nil?
        judge_entry = {entry: entry, timeslot: timeslot, as: 'judge'}

        judges[entry].each do |judge|
          if assignments.has_key?(judge)
            assignments[judge].push(judge_entry)
          else
            assignments[judge] = [judge_entry]
          end
        end
      end
    end

    Rails.cache.write("selected", selected)
    Rails.cache.write("judges", judges)
    Rails.cache.write("assignments", assignments)
  end

end
