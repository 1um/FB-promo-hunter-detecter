module TestConstants
  @@bad_words = {"акц"=>0.5, "выйгра"=>0.5, "приз"=>0.5, "сюрприз"=>0.5, "розыгрыш"=>0.5, "розыгрыва"=>0.5, "подарок"=>0.5, "подар"=>0.5, "конкурс"=>0.5, "побед"=>0.5, "победител"=>0.5, "везунчик"=>0.5, "услов"=>0.5, "участ"=>0.5, "участник"=>0.5, "репост"=>0.5, "расшар"=>0.5, "присоедин"=>0.5, "подпиш"=>0.5, "голос"=>0.5, "случай"=>0.5}
  @@ph_post_percent = 0.5
  def self.bad_words
    @@bad_words
  end

  def self.bad_words=bw
    @@bad_words = bw
  end

  def self.ph_post_percent
    @@ph_post_percent
  end

  def self.ph_post_percent= per
    @@ph_post_percent = per
  end

end