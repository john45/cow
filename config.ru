#!/bin/env ruby
# encoding: utf-8

# действия:
# поиграть
# наказать
# покормить
# уложить спать
# покупать

# метрики:
# желание спать = да/нет
#   состояние сна (1..3, 4..10)
# сытость (1..10)
# настроение(1..10)
# нужда туалета(1..3, 4..10) да/нет

use Rack::Static, :urls => ["/media"]

class App

  class Cow
    attr_reader :name, :stuff_in_belly, :mood, :sleep, :toilet
    attr_accessor :exit_, :message

    def initialize name
      @name = name
      @sleep = false      #желание сна
      @count_sleep = 10   #колличество бодрстволвания
      @stuff_in_belly = 10  #  желудок
      @toilet =  false
      @count_toilet =  0  #  кишечник
      @mood = 10          # Настроение
      @exit_ = false
      @message = ''
    end

    def feed
      @stuff_in_belly = 10
      passage_of_time
    end

    def walk
      @mood = 10
      passage_of_time
    end

    def put_to_bed
      @sleep = false
      3.times { passage_of_time }
    end

    def go_to_wind
      @count_toilet = 0
      @toilet = false
      passage_of_time
    end

    def push
      @mood -= 1
      passage_of_time
    end


    private

      #  "private" означает, что определённые здесь методы являются
      #  внутренними методами этого объекта.  (Вы можете кормить
      #  вашего дракона, но не можете спросить его, голоден ли он.)

      def hungry?  #  голоден?
        #  Имена методов могут заканчиваться знаком "?".
        #  Как правило, мы называем так только, если метод
        #  возвращает true или false, как здесь:
        @stuff_in_belly <= 2
      end

      def mood?
        @mood == 0
      end

      def toilet?  #  кишечник полон?
        @count_toilet >= 8
      end

      def passage_of_time # проходит некоторое время
        @message = ''

        if @stuff_in_belly > 0
          #  Переместить пищу из желудка в кишечник.
          @stuff_in_belly -= 1
          @count_toilet += 1
        else  #  Наш дракон страдает от голода!
          if @sleep
            @sleep = false
          end
          @message +=  @name + ' голодная корова убежала от вас в лес'
          @exit_ = true
        end

        if @count_toilet >= 10
          @count_toilet = 0
          @message +=  'Опаньки!  ' + @name + ' сделала нехорошо...'
        end

        if hungry?
          if @sleep
            @sleep = false
            @message +=  'Она внезапно просыпается!'
          end
          @message +=  'В желудке у ' + @name + '(а) урчит...'
        end

        if mood?
          @mood -= 1
          @message += 'Корова от злости вас забодала'
          @exit_ = true
        end

        if toilet?
          if @sleep
            @sleep = false
            @message +=  'Он внезапно просыпается!'
          end
          @message +=  @name + ' подпрыгивает, потому что хочет на горшок...'
        end
      end
  end

  def call(env)
    req = Rack::Request.new(env)
    links = "<a href='/walk' >Выгулять      </a>
             <a href='/feed' >Кормить      </a>
             <a href='/put_to_bed' >Уложить спать      </a>
             <a href='/go_to_wind' >Сводить в туалет      </a>
             <a href='/push' >Стукнуть      </a><br>"

    case req.path_info
    when /index/
      @@cow = Cow.new('Cowy')
      [200, {"Content-Type" => "text/html"}, [links, "Name of our cow is _#{@@cow.name}_","<br>",
                                              "cow want sleep: #{@@cow.sleep}","<br>",
                                              "cow want eat: #{@@cow.stuff_in_belly}","<br>",
                                              "cow want go to wind: #{@@cow.toilet}","<br>",
                                              "cow mood: #{@@cow.mood}","<br>",
                                              "<img src='/media/cowy.jpg' height='150' width='150' alt='тут фотка коровы'>",
                                              "<br><b>",@@cow.message,"<br><b>"]]


    when /walk/
      if @@cow.exit_
              [404, {"Content-Type" => "text/html"}, ["<a href='/index' >Вырастить новую коровку      </a>",
                                                      "<img src='/media/go_to_les.jpg' height='150' width='150' alt='тут фотка коровы'>","<br>",
                                                      "<br><b>",@@cow.message,"<br><b>"]]
      end
      @@cow.walk
      [200, {"Content-Type" => "text/html"}, [links,"Name of our cow is _#{@@cow.name}_","<br>",\
                                              "cow want sleep: #{@@cow.sleep}","<br>",
                                              "cow want eat: #{@@cow.stuff_in_belly}","<br>",
                                              "cow want go to wind: #{@@cow.toilet}","<br>",
                                              "cow mood: #{@@cow.mood}","<br>",
                                              "<img src='/media/fun.jpg' height='150' width='150' alt='тут фотка коровы'>",
                                            "<br><b>",@@cow.message,"<br><b>"]]
    when /feed/
      if @@cow.exit_
              [404, {"Content-Type" => "text/html"}, ["<a href='/index' >Вырастить новую коровку      </a>",
                                                      "<img src='/media/go_to_les.jpg' height='150' width='150' alt='тут фотка коровы'>","<br>",
                                                      "<br><b>",@@cow.message,"<br><b>"]]
      end
      @@cow.feed
      [200, {"Content-Type" => "text/html"}, [links,"Name of our cow is _#{@@cow.name}_","<br>",\
                                              "cow want sleep: #{@@cow.sleep}","<br>",
                                              "cow want eat: #{@@cow.stuff_in_belly}","<br>",
                                              "cow want go to wind: #{@@cow.toilet}","<br>",
                                              "cow mood: #{@@cow.mood}","<br>",
                                              "<img src='/media/feed.jpg' height='150' width='150' alt='тут фотка коровы'>",
                                            "<br><b>",@@cow.message,"<br><b>"]]
    when /put_to_bed/
      if @@cow.exit_
              [404, {"Content-Type" => "text/html"}, ["<a href='/index' >Вырастить новую коровку      </a>",
                                                      "<img src='/media/go_to_les.jpg' height='150' width='150' alt='тут фотка коровы'>","<br>",
                                                      "<br><b>",@@cow.message,"<br><b>"]]
      end
    @@cow.put_to_bed
    [200, {"Content-Type" => "text/html"}, [links,"Name of our cow is _#{@@cow.name}_","<br>",\
                                            "cow want sleep: #{@@cow.sleep}","<br>",
                                            "cow want eat: #{@@cow.stuff_in_belly}","<br>",
                                            "cow want go to wind: #{@@cow.toilet}","<br>",
                                            "cow mood: #{@@cow.mood}","<br>",
                                            "<img src='/media/sleep.jpg' height='150' width='150' alt='тут фотка коровы'>",
                                            "<br><b>",@@cow.message,"<br><b>"]]
    when /go_to_wind/
      if @@cow.exit_
              [404, {"Content-Type" => "text/html"}, ["<a href='/index' >Вырастить новую коровку      </a>",
                                                      "<img src='/media/go_to_les.jpg' height='150' width='150' alt='тут фотка коровы'>","<br>",
                                                      "<br><b>",@@cow.message,"<br><b>"]]
      end
    @@cow.go_to_wind
    [200, {"Content-Type" => "text/html"}, [links,"Name of our cow is _#{@@cow.name}_","<br>",\
                                            "cow want sleep: #{@@cow.sleep}","<br>",
                                            "cow want eat: #{@@cow.stuff_in_belly}","<br>",
                                            "cow want go to wind: #{@@cow.toilet}","<br>",
                                            "cow mood: #{@@cow.mood}","<br>",
                                            "<img src='/media/toilet.gif' height='150' width='150' alt='тут фотка коровы'>",
                                            "<br><b>",@@cow.message,"<br><b>"]]
    when /push/
      if @@cow.exit_
              [404, {"Content-Type" => "text/html"}, ["<a href='/index' >Вырастить новую коровку      </a>",
                                                      "<img src='/media/go_to_les.jpg' height='150' width='150' alt='тут фотка коровы'>","<br>",
                                                      "<br><b>", @@cow.message, "<br><b>"]]
      else
        @@cow.push
        [200, {"Content-Type" => "text/html"}, [links,"Name of our cow is _#{@@cow.name}_","<br>",\
                                            "cow want sleep: #{@@cow.sleep}","<br>",
                                            "cow want eat: #{@@cow.stuff_in_belly}","<br>",
                                            "cow want go to wind: #{@@cow.toilet}","<br>",
                                            "cow mood: #{@@cow.mood}","<br>",
                                            "<img src='/media/push.jpg' height='150' width='150' alt='тут фотка коровы'>",
                                            "<br><b>",@@cow.message,"<br><b>"]]
      end

    else
      @@cow.message = 'Коровка не понимает что вы от неё хотите'
      [404, {"Content-Type" => "text/html"}, [links,"Name of our cow is _#{@@cow.name}_","<br>",\
                                            "cow want sleep: #{@@cow.sleep}","<br>",
                                            "cow want eat: #{@@cow.stuff_in_belly}","<br>",
                                            "cow want go to wind: #{@@cow.toilet}","<br>",
                                            "cow mood: #{@@cow.mood}","<br>",
                                            "<img src='/media/to_moon.jpg' height='150' width='150' alt='тут фотка коровы'>","<br>",
                                            "<br><b>",@@cow.message,"<br><b>"]]
    end
  end
end

run App.new
# to run server 'rackup config.ru' in terminal