-- elusive

function init()
    y = 32
    height = 64
    width = 128
    amp = 10
    freq = 10
    start = 1
    
    audio.level_cut(1.0)
      audio.level_adc_cut(1)
      audio.level_eng_cut(1)
    softcut.level(1,1.0)
    softcut.level_slew_time(1,0.25)
      softcut.level_input_cut(1, 1, 1.0)
      softcut.level_input_cut(2, 1, 1.0)
      softcut.pan(1, 0.0)
  
    softcut.play(1, 1)
      softcut.rate(1, 1)
    softcut.rate_slew_time(1,0.25)
      softcut.loop_start(1, 1)
      softcut.loop_end(1, 1.5)
      softcut.loop(1, 1)
      softcut.fade_time(1, 0.1)
      softcut.rec(1, 1)
      softcut.rec_level(1, 1)
      softcut.pre_level(1, 0.75)
      softcut.position(1, 1)
      softcut.enable(1, 1)
  
      softcut.filter_dry(1, 0.125);
      softcut.filter_fc(1, 1200);
      softcut.filter_lp(1, 0);
      softcut.filter_bp(1, 1.0);
      softcut.filter_rq(1, 2.0);
  end
  
  function redraw()
    screen.clear()
    screen.level(15)
    
    if y == height/2 then
      start = 1
    end
    
    for x = 1,width do
      y = height/2 + amp * math.sin(start+x/freq)
      screen.pixel(x, y)
      screen.fill()
    end
    
    start=start+.5

    screen.move(128,10)
    screen.text_right(..freq..":"..amp)
    screen.update()
  end
  
  function enc(n,d)
    if n == 2 then
      amp = amp + d
      softcut.level(1,d)
    elseif n == 3 then
      freq = freq + d
      softcut.rate(1,d)
    end
  end
  
  -- Interval
  
  re = metro.init()
  re.time = 1.0 / 15
  re.event = function()
    redraw()
  end
  re:start()
  