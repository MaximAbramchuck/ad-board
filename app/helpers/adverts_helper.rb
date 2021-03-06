module AdvertsHelper
  def available_states_for(advert)
    available = []
    if current_user.admin? && advert.awaiting_publication?
      available << [:decline, :publish]
    end
    unless advert.archived?
      available << :archive
    end
    if advert.new? || advert.archived?
      available << :send_for_publication
    end
    available.flatten
  end

  def formatted_time_from_now(advert)
    " #{distance_of_time_in_words(Time.now-advert.created_at)}"
  end
end
