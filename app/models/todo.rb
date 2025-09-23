class Todo < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :priority, inclusion: { in: 1..5 }, allow_nil: true

  scope :completed, -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }
  scope :high_priority, -> { where("priority <= ?", 2) }
end
