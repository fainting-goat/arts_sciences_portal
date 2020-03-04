json.extract! scoresheet, :id, :score_id, :user_id, :entry_id, :created_at, :updated_at
json.url scoresheet_url(scoresheet, format: :json)
