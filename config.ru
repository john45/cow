#!/bin/env ruby
# encoding: utf-8
use Rack::Static, :urls => ["/media"]

class App
  # $LOAD_PATH << '.'
  # require 'cow'

  class Cow

    attr_accessor :name, :stuffInBelly, :mood

    def initialize name
      @name = name
      @sleep = false
      @stuffInBelly = 10  #  Он сыт.
      @toilet =  0  #  Ему не надо гулять.
      @mood = 10
    end

    def feed
      @stuffInBelly = 10
      passageOfTime
    end

    def walk
      @mood = 10
      passageOfTime
    end

    def put_to_bed
      @asleep = true
      3.times do
        if @sleep
          passageOfTime
        end
      end
      if @sleep
        @sleep = false
      end
    end

    private

      #  "private" означает, что определённые здесь методы являются
      #  внутренними методами этого объекта.  (Вы можете кормить
      #  вашего дракона, но не можете спросить его, голоден ли он.)

      def hungry?  #  голоден?
        #  Имена методов могут заканчиваться знаком "?".
        #  Как правило, мы называем так только, если метод
        #  возвращает true или false, как здесь:
        @stuffInBelly <= 2
      end

      def toilet?  #  кишечник полон?
        @toilet >= 8
      end

      def passageOfTime # проходит некоторое время
        if @stuffInBelly > 0
          #  Переместить пищу из желудка в кишечник.
          @stuffInBelly     -= 1
          @toilet += 1
        else  #  Наш дракон страдает от голода!
          if @sleep
            @sleep = false
          end
          @message =  @name + ' проголодался! Доведённый до крайности, он съедает ВАС!'
          exit  #  Этим методом выходим из программы.
        end

        if @stuffInIntestine >= 10
          @stuffInIntestine = 0
          @message =  'Опаньки!  ' + @name + ' сделал нехорошо...'
        end

        if hungry?
          if @asleep
            @asleep = false
            @message =  'Он внезапно просыпается!'
          end
          @message =  'В желудке у ' + @name + '(а) урчит...'
        end

        if poopy?
          if @asleep
            @asleep = false
            @message =  'Он внезапно просыпается!'
          end
          @message =  @name + ' подпрыгивает, потому что хочет на горшок...'
        end
      end
  end

  def call(env)
    cow = Cow.new('Muuu')
    req = Rack::Request.new(env)
    case req.path_info

    when /status/

      [200, {"Content-Type" => "text/html"}, ["#{cow.name}","cow mood: ","<br>","<img src='/media/cowy.jpg' alt='тут фотка коровы'>"]]

    when /feed/
      # do something with your Cow
      # store updated data to file || table || database || session
      # and render to the web:
      @@health += 1
      [200, {"Content-Type" => "text/html"}, ["<a href='/feed'>Feed Cow</a>#{@@status_bar_template_example}","<br>#{@@health}"]]
    else
      [404, {"Content-Type" => "text/html"}, ["I'm Lost!"]]
    end
  end
end

run App.new
# to run server 'rackup config.ru' in terminal