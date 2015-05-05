# encoding: utf-8
json.array!(@approvals) do |approval|
  json.extract! approval, :id, :date, :is_approved, :description, :user_id
  json.url approval_url(approval, format: :json)
end
