class Advert < ActiveRecord::Base
  paginates_per 10

  scope :including_all, -> { includes(:category, :images, :user) }
  scope :more_than_1_day, -> { where(state: :published).where('updated_at <= :day_ago', { day_ago: Time.now - 1.day }) }
  scope :published, -> { where(state: :published).including_all.order(updated_at: :desc) }
  scope :awaiting_publication, -> { where(state: :awaiting_publication).including_all.order(updated_at: :desc) }
  scope :declined, -> { where(state: :declined).including_all.order(updated_at: :desc) }
  scope :category_filter, ->(category){ where(state: :published).joins(:category).where("categories.name = ?",category) }
  scope :categories_count,  ->{ where(state: :published).joins(:category).group("categories.name").count }

  validates :name, :description, :price, :user_id, :category_id, presence: true

  belongs_to :user
  belongs_to :category
  has_many :operations
  has_many :images, as: :imageable, dependent: :destroy
  has_one :comment
  accepts_nested_attributes_for :images, reject_if: ->(t) { t['image'].nil? }, allow_destroy: true

  extend Enumerize
  enumerize :kind, in: [:sale, :purchase, :exchange, :service, :rent]

  include AASM
  aasm column: 'state', whiny_transitions: false do

    state :new, initial: true
    state :awaiting_publication
    state :declined
    state :published
    state :archived
    
    event :send_for_publication do
      transitions from: [:new, :archived], to: :awaiting_publication
    end

    event :archive do
      transitions from: [:new, :awaiting_publication, :declined, :published], to: :archived
    end

    event :publish do
      transitions from: :awaiting_publication, to: :published
    end

    event :decline do
      transitions from: :awaiting_publication, to: :declined
    end
  end

  def self.archive_old_adverts
    published_adverts = Advert.more_than_1_day
    published_adverts.find_each { |a| a.archive; a.save }
  end
end
