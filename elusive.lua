-- elusive

function init()
    y = 32
    height = 64
    width = 128
    baseline = 40
    amp = {10,10,10,10,10,10}
    freq = {10,10,10,10,10,10}
    start = 1

    active_waves = 1
    current_wave = 1

    audio.level_cut(1.0)
    audio.level_adc_cut(1)
    audio.level_eng_cut(1)

    for v = 1,6 do 
        softcut.level(v,1.0)
        softcut.level_slew_time(v,0.25)
        softcut.level_input_cut(v, 1, 1.0)
        softcut.pan(v, 0.0)
    
        softcut.play(v, 1)
        softcut.rate(v, 1)
        softcut.rate_slew_time(v,0.25)
        softcut.loop_start(v, 1)
        softcut.loop_end(v, 1.5)
        softcut.loop(v, 1)
        softcut.fade_time(v, 0.1)
        softcut.rec(v, 1)
        softcut.rec_level(v, 1)
        softcut.pre_level(v, 0)
        softcut.position(v, 1)
        softcut.enable(v, 1)
    
        softcut.filter_dry(v, 0.125);
        softcut.filter_fc(v, 1200);
        softcut.filter_lp(v, 0);
        softcut.filter_bp(v, 1.0);
        softcut.filter_rq(v, 2.0);
    end
    
    softcut.pre_level(current_wave, 0.75)
  end
  
  function redraw()
    screen.clear()
    
    if y == baseline then
      start = 1
    end
    
    for w = 1,6 do
        screen.level(15-w*2)
        if w <= active_waves then
            softcut.pre_level(w, .75)
            for x = 1,width do
                y = baseline + amp[w] * math.sin(start+x/freq[w])
                screen.pixel(x, y)
                screen.fill()
                
                -- filled
                -- screen.move(x,64)
                -- screen.line(x,y)
                -- screen.stroke()
            end
        else
            softcut.pre_level(w, 0)
        end
    end

    start=start+.25

    screen.move(60,60)
    screen.text_right(current_wave.."/"..active_waves.."/"..freq[current_wave]..'/'..amp[current_wave])
    screen.update()
  end

  function key(n,z)
    if z == 1 then
        if n == 3 then
            if active_waves < 6 then
                active_waves = active_waves + 1
            end
        elseif n == 2 then
            if active_waves > 0 then
                active_waves = active_waves - 1
            end
        end
    end
  end
  
  function enc(n,d)
    if n == 2 then
      amp[current_wave] = amp[current_wave] + d/10
      level = amp[current_wave]/100
      softcut.level(current_wave,level)
    elseif n == 3 then
      freq[current_wave] = freq[current_wave] + d/10
      rate = freq[current_wave]/100
      softcut.rate(current_wave,rate)
    elseif n == 1 then
      current_wave = util.clamp(current_wave + d,1,active_waves)
    end
  end
  
  -- Interval
  
  re = metro.init()
  re.time = 1.0 / 15
  re.event = function()
    redraw()
  end
  re:start()
  