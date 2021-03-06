class CriteriaType < ApplicationRecord
  has_many :applicable_criteriums
  has_many :criteriums
  belongs_to :parent, class_name: 'CriteriaType', optional: true
  has_many :children, class_name: 'CriteriaType', foreign_key: 'parent_id'

  ORDER_ARRAY = ["Research and Supporting Evidence", "Materials and Methods", "Scope", "Skill", "Ingenuity", "Judge's Observation"]

  scope :top_level, -> { where('parent_id is null') }
  scope :children, -> { where.not('parent_id is null') }
  scope :children_for, -> (parent) { where('parent_id = ?', parent.id) }
  scope :applicable, -> (category) { joins(:applicable_criteriums).where('applicable_criteria.category_id = ?', category.id) }
  scope :in_order, -> { sort_by{|thing| ORDER_ARRAY.index thing.description} }
end
