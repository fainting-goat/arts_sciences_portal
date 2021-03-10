module FairsHelper
  def scoresheets_visible?(fair, user)
    return true if fair.scoresheets_allowed
    entries = fair.entries.judge_assigned_entries(current_user).joins(:category).pluck(:'categories.mail_in')
    entries.include?(true) && fair.mail_in_scoresheets_allowed
  end

  def next_fair
    Fair.current.order(date: :asc).first
  end

  def next_kingdom_fair
    Fair.current.kingdom.order(date: :asc).first
  end

  def order_by_preference(collection, entry)
    collection.sort do |a, b|
      if a.judge_preferences.empty?
        1
      elsif b.judge_preferences.empty?
        0
      elsif a.judge_preferences.where(category_id: entry.category_id).empty?
        1
      else
        0
      end
    end
  end

  def is_selected?(selected, entry, timeslot)
    selected[entry.id.to_s] == timeslot.id.to_s
  end

  def is_judge_selected?(judges, entry, entrant)
    return false unless judges.has_key?(entry.id.to_s)
    judges[entry.id.to_s].include?(entrant.id.to_s)
  end

  def warn_of_dupes(assignments, entry, timeslot)
    entrants = UserEntry.where(entry_id: entry.id).pluck(:user_id)
    results = []

    # you didn't check the timeslot matches dumbass
    entrants.each do |entrant|
      if assignments.has_key?(entrant.to_s)
        person_assignment = assignments[entrant.to_s].reject{ |x| x[:timeslot].nil? }

        if person_assignment.reject { |x| x[:timeslot] != timeslot.id.to_s }.length == 1
          results.push("yellow-background")
        elsif person_assignment.reject { |x| x[:timeslot] != timeslot.id.to_s }.length > 1
          results.push("red-background")
        end
      end
    end

    return "red-background" if results.include?("red-background")
    return "yellow-background" if results.include?("yellow-background")

    ""
  end

  def warn_of_dupes_for_judges(assignments, selected, entry, user)
    return "" unless assignments.has_key?(user.id.to_s)

    person_assignment = assignments[user.id.to_s].reject{ |x| x[:timeslot].nil? }

    timeslot = selected[entry.id.to_s]
    return "" if timeslot.nil?

    return "" unless person_assignment.collect{ |x| x[:timeslot] }.include?(timeslot)

    return "yellow-background" if person_assignment.collect { |x| x[:timeslot] }.uniq.length == person_assignment.length
    "red-background"
  end
end